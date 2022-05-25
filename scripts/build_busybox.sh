#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building BusyBox"
mkdir -p "$BUSYBOX_BUILD"
cd "$BUSYBOX_BUILD"

[ -d "$BUSYBOX_SRC" ] || {
    tar --checkpoint=200 -xf "$BUSYBOX" || dd "Missing BusyBox src $BUSYBOX - try run 'make download'"
    cd "$BUSYBOX_SRC"
    make distclean
}
cd "$BUSYBOX_SRC"

configPresetPath="$NICE_PRESET_PATH/busybox.config"
if [ -r $configPresetPath ]; then
    cp "$configPresetPath" '.config'
else
    make defconfig > /dev/null
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
fi
grep -q 'CONFIG_STATIC=y' '.config' || dd "CONFIG_STATIC=y is required for busybox"

make $MAKEFLAGS busybox
make CONFIG_PREFIX="_install" install > /dev/null

mkdir -p "$TARGET/usr/bin"
pushd "$TARGET/usr/bin/"
    cp -f "$BUSYBOX_SRC/busybox" "busybox" && chmod o+rx "busybox"

    # Install busybox widgets if no $TARGET 'sh' and no 'core' counterparts is available
    if ([ ! -x "sh" ] || [ "busybox" == $(readlink "sh") ]); then
        widgets=$(find "$BUSYBOX_SRC/_install/" -type l -exec basename {} \;)
        for widgetName in $widgets; do
            ln -s busybox $widgetName 2> /dev/null || true
        done
    fi
popd

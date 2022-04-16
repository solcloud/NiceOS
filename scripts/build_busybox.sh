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

cp "$NICE_PRESET_PATH/busybox.config" '.config'
grep -q 'CONFIG_STATIC=y' '.config' || dd "CONFIG_STATIC=y is required for busybox"

if [ -z $ARCH ] && [ -e "/usr/src/niceOS.hash" ] && (! ldconfig -p | grep -E 'libg?crypt\.a') && (file /bin/busybox | grep 'statically linked'); then # arch removes static libcrypt
    notify "Using host static busybox"
    cp -f /bin/busybox "$BUSYBOX_SRC/busybox"
    usedHostBusybox=1
else
    make $MAKEFLAGS busybox
fi

mkdir -p "$TARGET/usr/bin"
# Install busybox widgets if no $TARGET 'sh' and no 'core' counterparts is available
if ([ ! -x "$TARGET/bin/sh" ] || [ "busybox" == $(readlink "$TARGET/bin/sh") ]); then
    if [ "$usedHostBusybox" == "1" ]; then
        widgets=$(./busybox --list)
    else
        make CONFIG_PREFIX="_install" install &> /dev/null
        widgets=$(find ./_install/ -type l -exec basename {} \;)
    fi
    pushd "$TARGET/usr/bin/"
        for widgetName in $widgets; do
            ln -s busybox $widgetName 2> /dev/null || true
        done
    popd
fi
cp -f "$BUSYBOX_SRC/busybox" "$TARGET/usr/bin/busybox"
chmod o+rx "$TARGET/usr/bin/busybox"

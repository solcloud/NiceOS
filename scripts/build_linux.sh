#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building Linux"

mkdir -p "$LINUX_BUILD"
cd "$LINUX_BUILD"

[ -d "$LINUX_SRC" ] || {
    tar --checkpoint=400 -xf "$LINUX" || dd "Missing linux kernel src $LINUX - try run 'make download'"
    cd "$LINUX_SRC"
    make mrproper
}
cd "$LINUX_SRC"

echo "Building kernel"
cp "$NICE_PRESET_PATH/linux.config" '.config'
make olddefconfig # comment for interactive asking
make $MAKEFLAGS vmlinux bzImage

HAS_MODULES_SUPPORT=$(source ./.config ; [ "y" == "$CONFIG_MODULES" ] && echo -n "1" || echo -n "0")
if [ "$HAS_MODULES_SUPPORT" == "1" ]; then
    echo "Building kernel modules"
    make $MAKEFLAGS modules
    echo "Installing kernel modules"
    make INSTALL_MOD_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 modules_install
fi

echo "Installing kernel headers"
make INSTALL_HDR_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 headers_install

if [ "$LINUX_COPY_SRC_TO_TARGET" = "1" ]; then
    mkdir -p "$TARGET/usr/src"
    rsync --archive --delete --chmod=o-rwx "$LINUX_SRC/" "$TARGET/usr/src/$LINUX_VERSION/"
    sed "s/xxLINUX_VERSIONxx/$LINUX_VERSION/" "$LINUX_BUILD/rebuild_and_reinstall.sh" > "$TARGET/usr/src/$LINUX_VERSION/rebuild_and_reinstall.sh"

    # Update modules kernel src symlink from absolute path to host into target relative path
    if [ "$HAS_MODULES_SUPPORT" == "1" ]; then
        pushd "$TARGET/usr/lib/modules/$LINUX_VERSION/"
            rm -f build source
            ln -s "../../../src/$LINUX_VERSION/" 'build'
            ln -s "../../../src/$LINUX_VERSION/" 'source'
        popd
    fi
fi


cp -f "$LINUX_SRC/.config" "$TARGET/boot/kernel.config"
cp -f "$LINUX_SRC/System.map" "$TARGET/boot/System.map"
cp -f "$LINUX_SRC/arch/x86/boot/bzImage" "$TARGET/boot/vmlinuz"

#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building Linux"
mkdir -p "$LINUX_BUILD"
cd "$LINUX_BUILD"

[ -d "$LINUX_SRC" ] || {
    tar --checkpoint=400 -xf "$LINUX" || dd "Missing Linux kernel src $LINUX - try run 'make download'"
    cd "$LINUX_SRC"
    make mrproper
}
cd "$LINUX_SRC"

echo "Building kernel"
cp "$NICE_PRESET_PATH/linux.config" '.config'
make olddefconfig # comment for interactive asking
make $MAKEFLAGS

grep -q '^CONFIG_MODULES=y$' .config && make INSTALL_MOD_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 modules_install || true
make INSTALL_HDR_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 headers_install

mkdir -p "$TARGET/usr/src"
sed "s/xxLINUX_VERSIONxx/$LINUX_VERSION/" "$LINUX_BUILD/rebuild_and_reinstall.sh" > "$TARGET/usr/src/rebuild_and_reinstall_linux.sh"

cp -f "$LINUX_SRC/.config" "$TARGET/boot/kernel.config"
cp -f "$LINUX_SRC/System.map" "$TARGET/boot/System.map"
cp -f "$LINUX_SRC/arch/${ARCH:-x86}/boot/"*Image "$TARGET/boot/vmlinuz"
[ -r "$LINUX_SRC/arch/${ARCH:-x86}/boot/dts/" ] && rm -rf "$TARGET/boot/dts/" && cp -r "$LINUX_SRC/arch/${ARCH:-x86}/boot/dts/" "$TARGET/boot/" || true

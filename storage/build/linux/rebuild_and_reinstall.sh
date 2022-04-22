#!/bin/sh

set -e

if ! findmnt /boot; then
    echo 'Mount /boot partition!'
    exit 1
fi
if ! test -r .config; then
    echo 'No .config found! Maybe use one from /boot/kernel.config'
    exit 1
fi

TARGET=''
LINUX_SRC="/usr/src/xxLINUX_VERSIONxx"

cd $LINUX_SRC

make $*
grep -q '^CONFIG_MODULES=y$' .config && make INSTALL_MOD_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 modules_install || true
make INSTALL_HDR_PATH="$TARGET/usr" INSTALL_MOD_STRIP=1 headers_install

cp -f $LINUX_SRC/.config $TARGET/boot/kernel.config
cp -f $LINUX_SRC/System.map $TARGET/boot/System.map
cp -f $LINUX_SRC/arch/$(uname -m)/boot/*Image $TARGET/boot/vmlinuz
[ -r "$LINUX_SRC/arch/$(uname -m)/boot/dts/" ] && rm -rf "$TARGET/boot/dts/" && cp -r "$LINUX_SRC/arch/$(uname -m)/boot/dts/" "$TARGET/boot/" || true

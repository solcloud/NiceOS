#!/bin/bash

if ! findmnt /boot; then
    echo 'Mount /boot partition!'
    exit 1
fi

TARGET=''
LINUX_SRC=/usr/src/$(uname -r)

cd $LINUX_SRC

make $* vmlinux bzImage modules
make INSTALL_MOD_PATH=$TARGET/usr INSTALL_MOD_STRIP=1 modules_install
make INSTALL_HDR_PATH=$TARGET/usr INSTALL_MOD_STRIP=1 headers_install

cp -f $LINUX_SRC/.config $TARGET/boot/kernel.config
cp -f $LINUX_SRC/System.map $TARGET/boot/System.map
cp -f $LINUX_SRC/arch/x86/boot/bzImage $TARGET/boot/vmlinuz

#!/bin/bash

set -e
source ./.config.sh

echo "Building Initramfs"

mkdir -p $INITRAMFS_BUILD
cd $INITRAMFS_BUILD

mkdir -p bin/ dev/ etc/ proc/ sys/ mnt/
cp -f $BUSYBOX_SRC/busybox bin/busybox
ln -s busybox bin/sh 2> /dev/null || true
chmod u+x init || dd "Init not found in $INITRAMFS_BUILD/init"

echo "Creating initramfs cpio archive"
find . -print0 | cpio --null -ov --format=newc | gzip --best > $BUILDS/initramfs.cpio.gz # TODO performance check for best algo or no compression at all
cp -f $BUILDS/initramfs.cpio.gz $TARGET/boot/initrd

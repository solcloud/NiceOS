#!/bin/bash

set -e
source ./_config.sh

echo "Building Initramfs"

mkdir -p $INITRAMFS_BUILD
cd $INITRAMFS_BUILD

mkdir -p bin/ dev/ etc/ proc/ sys/ mnt/
cp -f $BUSYBOX_SRC/busybox bin/busybox
ln -sf busybox bin/sh
chmod u+x init || dd "Init not found in $INITRAMFS_BUILD/init"

echo "Creating initramfs cpio archive"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $BUILDS/initramfs.cpio.gz # TODO performance check for best algo or no compression at all
cp -f $BUILDS/initramfs.cpio.gz $TARGET/boot/initrd

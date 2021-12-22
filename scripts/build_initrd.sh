#!/bin/bash

set -e
source ./_config.sh

echo "Building Initramfs"

mkdir -p $INITRAMFS_BUILD
cd $INITRAMFS_BUILD

mkdir -p bin/ dev/ etc/ proc/ sys/ mnt/
cp -f $BUSYBOX_SRC/busybox bin/busybox
ln -sf busybox bin/sh

# Init
[ -r "$NICE_PRESET_PATH/initrd/init" ] && cp -f "$NICE_PRESET_PATH/initrd/init" init || cat <<'INIT_EOF' > init
#!/bin/sh

PATH=/bin

busybox mount -t proc proc /proc -o nosuid,noexec,nodev
busybox mount -t sysfs sys /sys -o nosuid,noexec,nodev
busybox mount -t devtmpfs dev /dev # or busybox mdev -s if no kernel support for devfs

root_disk=$(busybox findfs 'UUID=4e696365-4f53-4e69-6365-4f534e696365' || busybox echo -n 'no-nice-root-device-found')
busybox mount -o ro $root_disk /mnt

if busybox ls /mnt/init > /dev/null; then
  exec busybox switch_root /mnt /init
else
  exec sh
fi
INIT_EOF
chmod u+x init

# Archive cpio
echo "Creating initramfs"
find . -print0 | cpio --null -ov --format=newc \
  | gzip -9 > $BUILDS/initramfs.cpio.gz # TODO performance check for best algo or no compression at all

cp -f $BUILDS/initramfs.cpio.gz $TARGET/boot/initrd

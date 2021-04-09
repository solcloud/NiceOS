echo "Starting installer"

mkfs.ext4 -F /dev/sda
mount /dev/sda /mnt/

basestrap /mnt $(cat /tmp/packages | xargs)

artix-chroot /mnt /bin/bash -c '

echo "Cleaning installation"
{
    TARGET=""
    # Cleanup some Arch files
    # find $TARGET/lib/ -maxdepth 1 -mindepth 1 -type d

    #rm -rf $TARGET/usr/lib/artix/
    #rm -rf $TARGET/usr/lib/audit/
    #rm -rf $TARGET/usr/lib/avahi/
    #rm -rf $TARGET/usr/lib/openrc/
    #rm -rf $TARGET/usr/lib/sysctl.d/

    #rm -rf $TARGET/usr/share/man/

    rm -f $TARGET/usr/lib/udev/*.sh
    rm -f $TARGET/usr/bin/66-*
    rm -f $TARGET/usr/bin/s6-*
}
'

sync
poweroff

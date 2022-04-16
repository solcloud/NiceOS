echo "Starting installer"
. /tmp/nice_os_settings.sh || exit 1
mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

# Copy keys from live CD
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

export XBPS_ARCH='x86_64'
repository='https://alpha.de.repo.voidlinux.org/current'
if [ -n "$NICE_ARCH" ] && [ "$NICE_ARCH" != "$XBPS_ARCH" ]; then
    export XBPS_ARCH="$NICE_ARCH"
    export XBPS_TARGET_ARCH="$NICE_ARCH"
    repository="$repository/$NICE_ARCH"
fi

xbps-install --yes -S -r /mnt -R "$repository" $(cat /tmp/packages.xbps.txt | xargs)

sync
umount /mnt/
poweroff

echo "Starting installer"
mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

# Copy keys from live CD
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

arch='x86_64'
repository='https://alpha.de.repo.voidlinux.org/current'
XBPS_ARCH=$arch xbps-install --yes -S -r /mnt -R "$repository" $(cat /tmp/packages.xbps.txt | xargs)

sync
umount /mnt/
poweroff

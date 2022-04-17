echo "Starting installer"
. /tmp/nice_os_settings.sh || exit 1

mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

loop=$(losetup --show -f -P /run/install/repo/images/install.img)
mkdir /fed && mount "$loop" /fed &> /dev/null
cd /fed
cp -r etc/anaconda.repos.d /etc/yum.repos.d
version=$(source /etc/os-release ; echo $VERSION_ID)

dnf install --installroot=/mnt --releasever=$version --setopt=install_weak_deps=False --setopt=keepcache=True --assumeyes --nogpgcheck --nodocs $(cat /tmp/packages.dnf.txt | xargs)

sync
umount /mnt/
poweroff

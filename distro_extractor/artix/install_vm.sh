echo "Starting installer"
. /tmp/nice_os_settings.sh || exit 1

mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/

# Add archlinux mirrorlist 2021-06-09 https://wiki.artixlinux.org/Main/Repositories#Arch_repositories
echo "Adding archlinux repositories"
pacman -Sy --noconfirm artix-archlinux-support > /dev/null
printf '

# Arch
[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
' >> /etc/pacman.conf
echo "Populating keys from archlinux"
pacman-key --populate archlinux


basestrap /mnt $(cat /tmp/packages.arch.txt | xargs)


sync
umount /mnt/
poweroff

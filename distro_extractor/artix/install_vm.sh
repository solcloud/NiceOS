mkfs.ext4 -m 0 -F /dev/sda
mount /dev/sda /mnt/
echo "Starting installer"

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
artix-chroot /mnt /bin/sh -c '
echo "Cleaning installation"

'

sync
umount /mnt/
poweroff

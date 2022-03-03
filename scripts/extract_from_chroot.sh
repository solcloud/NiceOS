#!/bin/bash

set -e
source ./.config.sh || exit 1

source "$BASE/distro_extractor/$DISTRO/inc.sh" || dd "File '$BASE/distro_extractor/$DISTRO/inc.sh' cannot be sourced"
command=$(distro_install_command)

if [ "0" == $(ls "$VM_MOUNT_ROOT" | wc -l) ]; then
    dd "Chroot path $VM_MOUNT_ROOT seems empty, probably tar failed"
elif [ "1" == $(ls "$VM_MOUNT_ROOT" | wc -l) ]; then
    # Rootfs has been pack in one folder
    export VM_MOUNT_ROOT="$VM_MOUNT_ROOT/$(ls "$VM_MOUNT_ROOT")"
fi
[ -e "$VM_MOUNT_ROOT/etc" ] || dd "Cannot find '$VM_MOUNT_ROOT/etc'"

notify "We need sudo for bind mounting, chroot and cleanup"
sudo cp /etc/resolv.conf "$VM_MOUNT_ROOT/etc/"

sudo mount --bind /sys "$VM_MOUNT_ROOT/sys"
sudo mount --bind /proc "$VM_MOUNT_ROOT/proc"
sudo mount --bind /dev "$VM_MOUNT_ROOT/dev"

[[ $(type -t chroot_pre_hook) == 'function' ]] && chroot_pre_hook || true
sudo chroot "$VM_MOUNT_ROOT" /bin/sh -c "'$command'"

sudo umount -l "$VM_MOUNT_ROOT/dev"
sudo umount -l "$VM_MOUNT_ROOT/proc"
sudo umount -l "$VM_MOUNT_ROOT/sys"

./scripts/extract.sh
sudo rm -rf "$VM_MOUNT_ROOT"

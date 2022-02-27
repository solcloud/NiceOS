#!/bin/bash

set -e
source ./.config.sh || exit 1

source "$BASE/distro_extractor/$DISTRO/inc.sh" || dd "File '$BASE/distro_extractor/$DISTRO/inc.sh' cannot be sourced"
command=$(distro_install_command)

notify "We need sudo for bind mounting, chroot and cleanup"
sudo mount --bind /sys "$VM_MOUNT_ROOT/sys"
sudo mount --bind /dev "$VM_MOUNT_ROOT/dev"
sudo mount --bind /proc "$VM_MOUNT_ROOT/proc"
sudo cp /etc/resolv.conf "$VM_MOUNT_ROOT/etc/"

sudo chroot "$VM_MOUNT_ROOT" /bin/sh -c "'$command'"

sudo umount "$VM_MOUNT_ROOT/proc"
sudo umount "$VM_MOUNT_ROOT/dev"
sudo umount "$VM_MOUNT_ROOT/sys"

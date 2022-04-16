#!/bin/bash

set -e
source ./.config.sh || exit 1

function requires_distro_variable() {
    if [ -z "$DISTRO" ]; then
        echo "You need to specify extracting distribution from $BASE/distro_extractor, use one of"
        ls -I 'README.md' "$BASE/distro_extractor"
        dd "use 'export DISTRO=artix' for example"
    fi
}


if [ -n "$DISTRO_ISO" ]; then
    requires_distro_variable
    which VBoxManage &> /dev/null && HYPERVISOR_CANDIDATE=virtualbox || true
    which qemu-system-x86_64 &> /dev/null && HYPERVISOR_CANDIDATE=qemu || true

    export HYPERVISOR=${HYPERVISOR:-"$HYPERVISOR_CANDIDATE"}
    export NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH=${NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH:-"$OPT/distro.img"}
    ./scripts/extract_from_vm.sh
    ./scripts/extract.sh

elif [ -n "$DISTRO_ROOTFS" ]; then
    requires_distro_variable
    export VM_MOUNT_ROOT="$STORAGE/temp/extract/rootfs_$(date +%s)" && mkdir -p "$VM_MOUNT_ROOT"
    notify "We need sudo for untar rootfs"
    sudo tar --checkpoint=100 -xf "$DISTRO_ROOTFS" -C "$VM_MOUNT_ROOT"
    ./scripts/extract_from_chroot.sh

elif [ -n "$DEBOOTSTRAP_SUITE" ]; then
    which debootstrap > /dev/null || dd "Debootstrap binary not found"

    export VM_MOUNT_ROOT="$STORAGE/temp/extract/debootstrap_$(date +%s)" && mkdir -p "$VM_MOUNT_ROOT"
    notify "We need sudo for debootstrap and cleanup"
    [ -n "$NICE_ARCH" ] && arch="--foreign --arch='$NICE_ARCH'" || true
    sudo debootstrap --variant=minbase --merged-usr $arch --include="$(cat "$NICE_PRESET_PATH/packages.deb.txt" | xargs | sed 's/ /,/g')" "$DEBOOTSTRAP_SUITE" "$VM_MOUNT_ROOT" "$DEBOOTSTRAP_MIRROR" "$DEBOOTSTRAP_SCRIPT"
    ./scripts/extract.sh
    [ -n "$arch" ] && echo "Copying second stage debootstrap" && rm -rf "$TARGET/debootstrap/" && sudo cp -a "$VM_MOUNT_ROOT/debootstrap/" "$TARGET/" || true
    sudo rm -rf "$VM_MOUNT_ROOT"

else
    echo "You need to provide extract method. Use one of:"
    echo "'DISTRO_ISO' OR 'DISTRO_ROOTFS' OR 'DEBOOTSTRAP_SUITE'"
    dd "For example use 'export DISTRO_ISO=/data/dwn/artix-base-openrc-20220123-x86_64.iso'"
fi

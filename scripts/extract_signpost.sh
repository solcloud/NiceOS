#!/bin/bash

set -e
source ./.config.sh || exit 1

function requires_distro_variable() {
    if [ -z "$DISTRO" ]; then
        echo "You need to specify extracting distribution from $BASE/distro_extractor, use one of"
        ls "$BASE/distro_extractor"
        dd "use \`export DISTRO=artix\` for example"
    fi
}


if [ -n "$DISTRO_ISO" ]; then
    requires_distro_variable
    which VBoxManage &> /dev/null && HYPERVISOR_CANDIDATE=virtualbox || true
    which qemu-system-x86_64 &> /dev/null && HYPERVISOR_CANDIDATE=qemu || true

    export HYPERVISOR=${HYPERVISOR:-"$HYPERVISOR_CANDIDATE"}
    ./scripts/extract_from_vm.sh
    ./scripts/extract.sh

elif [ -n "$DISTRO_ROOTFS" ]; then
    requires_distro_variable
    export NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH=/tmp/nice-not-exists.noimg
    export VM_MOUNT_ROOT="$STORAGE/temp/extract/rootfs_$(date +%s)" && mkdir -p "$VM_MOUNT_ROOT"
    tar --checkpoint=100 -xf "$DISTRO_ROOTFS" -C "$VM_MOUNT_ROOT"
    ./scripts/extract_from_chroot.sh
    ./scripts/extract.sh
    sudo rm -rf "$VM_MOUNT_ROOT"

elif [ -n "$DEBOOTSTRAP_SUITE" ]; then
    which debootstrap > /dev/null || dd "Debootstrap binary not found"

    export VM_MOUNT_ROOT="$STORAGE/temp/extract/debootstrap_$(date +%s)" && mkdir -p "$VM_MOUNT_ROOT"
    export NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH=/tmp/nice-not-exists.noimg
    notify "We need sudo for debootstrap and cleanup"
    sudo debootstrap --variant=minbase --merged-usr --arch="${ARCH:-amd64}" --include="$(cat "$NICE_PRESET_PATH/packages.deb.txt" | xargs | sed 's/ /,/g')" "$DEBOOTSTRAP_SUITE" "$VM_MOUNT_ROOT" "$DEBOOTSTRAP_MIRROR" "$DEBOOTSTRAP_SCRIPT"
    ./scripts/extract.sh
    sudo rm -rf "$VM_MOUNT_ROOT"

else
    echo "You need to provide extract method. Use one of:"
    echo "'DISTRO_ISO' OR 'DISTRO_ROOTFS' OR 'DEBOOTSTRAP_SUITE'"
    dd "For example use \`export DISTRO_ISO=/data/dwn/artix-base-openrc-20220123-x86_64.iso\`"
fi
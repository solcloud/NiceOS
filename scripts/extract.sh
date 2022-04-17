#!/bin/bash

source ./.config.sh || exit 1

if ! ([ -n "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH" ] || [ -d "$VM_MOUNT_ROOT" ]); then
    dd "Can only extract from '$VM_MOUNT_ROOT' OR from 'NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH'"
fi

if [ -r "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH" ]; then
    notify 'We need sudo for mounting'
    sudo umount "$VM_MOUNT_ROOT/" 2> /dev/null
    LOOP=$(sudo losetup --nooverlap --show -f -P "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH")
    mkdir -p "$VM_MOUNT_ROOT/"
    sudo mount "$LOOP" "$VM_MOUNT_ROOT/"
    echo "Mounted VM disk loop $LOOP at $VM_MOUNT_ROOT"
fi

{
    echo "Copying files from '$VM_MOUNT_ROOT' to '$TARGET'"
    notify 'We need sudo for copying'

    echo "Copying: usr/"
    rm -rf "$TARGET/usr/"
    sudo cp -a "$VM_MOUNT_ROOT/usr/" "$TARGET/"

    echo "Copying: var/"
    rm -rf "$TARGET/var/"
    sudo cp -a "$VM_MOUNT_ROOT/var/" "$TARGET/var/"

    if [ -r "$VM_MOUNT_ROOT/etc/fonts/" ]; then
        echo "Copying: etc/fonts/"
        rm -rf "$TARGET/etc/fonts/"
        mkdir -p "$TARGET/etc/"
        sudo cp -a "$VM_MOUNT_ROOT/etc/fonts/" "$TARGET/etc/"
    fi

    if [ -r "$VM_MOUNT_ROOT/etc/alternatives/" ]; then
        echo "Copying: etc/alternatives/"
        rm -rf "$TARGET/etc/alternatives/"
        mkdir -p "$TARGET/etc/"
        sudo cp -a "$VM_MOUNT_ROOT/etc/alternatives/" "$TARGET/etc/"
    fi

    echo "Changing ownership of '$TARGET' recursively to '$TARGET_USER:$TARGET_GROUP'"
    sudo chown -R "$TARGET_USER":"$TARGET_GROUP" "$TARGET"
    chmod -R u+rwX "$TARGET"
}

sync && sudo sync
echo "Done, checking git status"
git status

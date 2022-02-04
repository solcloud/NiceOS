#!/bin/bash

source ./.config.sh || exit 1

if ! ([ -r "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH" ] || mountpoint -q "$VM_MOUNT_ROOT"); then
    dd "Can only extract from already mounted '$VM_MOUNT_ROOT' OR from '$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH'"
fi

if [ -r "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH" ]; then
    notify 'We need sudo for mounting'
    sudo umount "$VM_MOUNT_ROOT/" 2> /dev/null
    LOOP=$(sudo losetup --nooverlap --show -f -P "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH")
    mkdir -p "$VM_MOUNT_ROOT/"
    sudo mount "$LOOP" "$VM_MOUNT_ROOT/"
    echo "Mount VM hdd loop $LOOP at $VM_MOUNT_ROOT"
fi

{
    echo "Copying distro $VM_MOUNT_ROOT files to $TARGET"
    notify 'We need sudo for copying'

    echo "Copying usr/ directory"
    rm -rf "$TARGET/usr/"
    sudo cp -a "$VM_MOUNT_ROOT/usr/" "$TARGET/"

    echo "Copying var/ directory"
    rm -rf "$TARGET/var/"
    sudo cp -a "$VM_MOUNT_ROOT/var/" "$TARGET/var/"

    if [ -r "$VM_MOUNT_ROOT/etc/fonts/" ]; then
        echo "Copying fonts configs"
        rm -rf "$TARGET/etc/fonts/"
        mkdir -p "$TARGET/etc/"
        sudo cp -a "$VM_MOUNT_ROOT/etc/fonts/" "$TARGET/etc/"
    fi

    if [ -r "$VM_MOUNT_ROOT/etc/alternatives/" ]; then
        echo "Copying /etc/alternatives/"
        rm -rf "$TARGET/etc/alternatives/"
        mkdir -p "$TARGET/etc/"
        sudo cp -a "$VM_MOUNT_ROOT/etc/alternatives/" "$TARGET/etc/"
    fi

    echo "Changing ownership of $TARGET recursively to $TARGET_USER:$TARGET_GROUP"
    sudo chown -R "$TARGET_USER":"$TARGET_GROUP" "$TARGET"

    echo "Removing $TARGET/usr/lib/udev/rules.d/"
    rm -rf "$TARGET/usr/lib/udev/rules.d/"
}

sync && sudo sync
echo "Done, checking git status"
git restore target/var/run
git checkout target/var/run
git status

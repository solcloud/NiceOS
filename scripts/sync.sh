#!/bin/bash

set -e
source ./.config.sh || exit 1

if [ "$NICE_HAS_PRIMARY_DISK" = "0" ]; then
    exit 0
fi


function unmount_paths() {
    echo "Unmounting $MOUNT_PATH/boot"
    sudo umount "$MOUNT_PATH/boot" || true
    echo "Unmounting $MOUNT_PATH/"
    sudo umount "$MOUNT_PATH/" || true
}

{
    if [ ! -f "$DISK_FILE" ] ; then
        echo "Creating disk image $DISK_FILE"
        if ! fallocate -l "${DISK_SIZE_GB}G" "$DISK_FILE"; then # some systems has buggy or no fallocate at all so try dd if it fails
            /bin/dd if=/dev/zero of="$DISK_FILE" bs=1G seek="$DISK_SIZE_GB" count=0 || dd "Unable to create '$DISK_FILE' with $DISK_SIZE_GB GB"
        fi
        printf "g\nn\n\n\n+100M\nn\n\n\n\nw\n" | fdisk "$DISK_FILE" # GPT with 2 partitions, first: 100M, second: rest of disk, defaults sector sizes
    fi
}

notify "Need sudo for target disk setup"

if findmnt "$MOUNT_PATH"; then
    notify "$MOUNT_PATH already mounted, forcing unmount in 4 sec, Ctr-C to cancel"
    sleep 4
    unmount_paths
fi

{
    echo "Mounting and rsyncing $TARGET to $MOUNT_PATH"
    LOOP=$(sudo losetup --nooverlap --show -f -P "$DISK_FILE")
    echo "Created $LOOP from $DISK_FILE"

    if ! sudo blkid | grep "${LOOP}p1" | grep -q '"6E69-6365"'; then
        echo "Formatting partitions"
        sudo mkfs.fat -F32 "${LOOP}p1" -i '6E696365'
        sudo mkfs.ext4 -m 0 -F "${LOOP}p2" -U '4e696365-4f53-4e69-6365-4f534e696365'
    fi

    echo "Mounting $MOUNT_PATH"
    sudo mkdir -p "$MOUNT_PATH" || dd "Cannot create mount directory $MOUNT_PATH"
    sudo mount "${LOOP}p2" "$MOUNT_PATH"

    echo "Syncing $TARGET to $MOUNT_PATH"
    sudo rsync --info=progress2 --exclude '/boot/' --archive --delete --chmod=D0755,Fo-w --chown 0:0 "$TARGET/" "$MOUNT_PATH" || {
        unmount_paths
        dd "Rsync to $MOUNT_PATH failed"
    }

    echo "Mounting $MOUNT_PATH/boot"
    sudo mkdir -p "$MOUNT_PATH/boot"
    sudo mount "${LOOP}p1" "$MOUNT_PATH/boot"

    echo "Syncing $TARGET/boot to $MOUNT_PATH/boot"
    sudo rsync --info=progress2 --recursive --times --delete "$TARGET/boot/" "$MOUNT_PATH/boot" || { # need separate non archive rsync for boot dir only because of permissions on FAT
        unmount_paths
        dd "Rsync to $MOUNT_PATH/boot failed"
    }

    # Replace some presets TARGET specific files
    [ -d "$NICE_PRESET_PATH/target" ] && sudo rsync --info=progress2 --archive --ignore-times --copy-links --copy-unsafe-links --chmod=D0755,Fo-w --chown 0:0 "$NICE_PRESET_PATH/target/" "$MOUNT_PATH" || true
    [ -d "$NICE_PRESET_PATH/target.dontfollowsymlink" ] && sudo rsync --info=progress2 --links --archive --ignore-times --chmod=D0755,Fo-w --chown 0:0 "$NICE_PRESET_PATH/target.dontfollowsymlink/" "$MOUNT_PATH" || true

    # NICE_PRESET as hostname and in hosts
    echo "$NICE_PRESET" > "$OPT/_sync.tmp.in"
    sudo cp "$OPT/_sync.tmp.in" "$MOUNT_PATH/etc/hostname"  
    sudo cat "$MOUNT_PATH/etc/hosts" | sed "s/nice/$NICE_PRESET/g" > "$OPT/_sync.tmp.in"
    sudo cp "$OPT/_sync.tmp.in" "$MOUNT_PATH/etc/hosts"
    rm "$OPT/_sync.tmp.in"
}


sudo sync && unmount_paths
echo "Syncing done"

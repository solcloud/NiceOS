#!/bin/bash

source ./.config.sh

IMAGE_PATH="$VIRTUAL_BOX_VMS_ROOT/nice/nice.vdi"
echo "Using virtual disk $IMAGE_PATH with UUID $VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID"
sleep 2

./scripts/sync.sh
rm "$IMAGE_PATH"
VBoxManage convertfromraw "$STORAGE/sda.img" "$IMAGE_PATH" --uuid "$VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID"

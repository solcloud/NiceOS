#!/bin/bash

set -e
source ./.config.sh || exit 1

IMAGE_PATH="$VIRTUAL_BOX_VMS_ROOT/niceOS.vdi"
echo "Using virtual disk '$IMAGE_PATH' with UUID '$VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID'"
sleep 2

rm -f "$IMAGE_PATH"
VBoxManage convertfromraw "$STORAGE/sda.img" "$IMAGE_PATH" --uuid "$VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID"

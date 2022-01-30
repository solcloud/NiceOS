#!/bin/bash

set -e
source ./.config.sh

rm -f "$DISK_FILE"

./scripts/build_linux.sh
./scripts/build_busybox.sh
./scripts/build_initrd.sh
./scripts/build_target.sh

./scripts/check.sh
./scripts/sync.sh

notify "Building done"

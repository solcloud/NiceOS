#!/bin/bash

set -e
source ./_config.sh

rm -f "$DISK_FILE"

./build_linux.sh
./build_busybox.sh
./build_initrd.sh
./build_target.sh

./check.sh
./sync.sh

notify "Building done"

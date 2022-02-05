#!/bin/bash

set -e

echo 'sleep 2 && cat /usr/test.txt && poweroff' > target/etc/start_services.sh
chmod u+x target/etc/start_services.sh

export NICE_PRESET=base
bash -c '
    source ./.config.sh || exit 1
    mkdir -p "$VM_MOUNT_ROOT/usr/"
    echo "Test file" > "$VM_MOUNT_ROOT/usr/test.txt"
'

echo "::group::Test extract"
./scripts/extract.sh
echo "::endgroup::"

echo "::group::Make download"
make download
echo "::endgroup::"

echo "::group::Make build"
make build
echo "::endgroup::"

echo "::group::Run QEMU"
make cmd
echo "::endgroup::"

rm target/etc/start_services.sh
echo "Tests passed"

#!/bin/bash

set -e

export NICE_PRESET=base
export VM_MOUNT_ROOT=/tmp/nice_os_extract_stub
export NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH=/tmp/nice-not-exists.noimg

cp storage/test_service.sh target/etc/start_services.sh
chmod u+x target/etc/start_services.sh

echo "::group::Test extract"
mkdir -p "$VM_MOUNT_ROOT/usr/"
echo "Test file" > "$VM_MOUNT_ROOT/usr/test.txt"
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

#!/bin/sh

set -e

echo 'sleep 2 && poweroff' > target/etc/start_services.sh
chmod u+x target/etc/start_services.sh

export NICE_PRESET=base
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

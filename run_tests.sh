#!/bin/sh

set -e

echo 'sleep 2 && poweroff' > target/etc/start_services.sh
chmod u+x target/etc/start_services.sh

export NICE_PRESET=base
make download
make build
make cmd

rm target/etc/start_services.sh

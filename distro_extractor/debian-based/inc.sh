#!/bin/bash

PM=deb

function distro_install_command() {
    packages=$(cat "$NICE_PRESET_PATH/packages.${PM}.txt" | xargs)
    echo "apt-get update && apt-get install --no-install-recommends --assume-yes $packages"
}

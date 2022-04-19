#!/bin/bash

PM=zypp

function distro_install_command() {
    packages=$(cat "$NICE_PRESET_PATH/packages.${PM}.txt" | xargs)
    echo "zypper install -y $packages"
}

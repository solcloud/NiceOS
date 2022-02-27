#!/bin/bash

PM=arch

function distro_install_command() {
    packages=$(cat "$NICE_PRESET_PATH/packages.${PM}.txt" | xargs)
    echo "pacman -Sy --noconfirm $packages"
}

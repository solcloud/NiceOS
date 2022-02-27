#!/bin/bash

PM=xbps
VM_USER=anon
VM_PASS=voidlinux

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Start boot by pressing enter or wait 10 sec"
    echo "After boot finished"
}

function distro_install_command() {
    packages=$(cat "$NICE_PRESET_PATH/packages.${PM}.txt" | xargs)
    echo "xbps-install --yes -S $packages"
}

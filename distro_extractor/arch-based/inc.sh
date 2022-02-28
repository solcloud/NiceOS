#!/bin/bash

PM=arch

function distro_install_command() {
    packages=$(cat "$NICE_PRESET_PATH/packages.${PM}.txt" | xargs)

    # Disable pacman checking free space
    echo -n 'cat /etc/pacman.conf | sed "s/CheckSpace/#CheckSpace/" > /tmp/pacman.conf && '
    echo -n 'cp /tmp/pacman.conf /etc/pacman.conf && '

    # Add default server and initialize keys
    echo -n 'echo "Server = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch" >> "/etc/pacman.d/mirrorlist" && '
    echo -n "pacman-key --init && pacman-key --populate archlinux && pacman -Sy --noconfirm $packages"
}

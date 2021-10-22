#!/bin/bash

VM_USER=devuan

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Select Devuan Live Minimal (std)"
    echo "After boot"
    echo "Login as root:toor"
    echo "Set keytable if desirable"
    echo "example 'loadkeys cz-us-qwertz'"
    echo "Run dhclient"
    echo "Run usermod -aG sudo devuan"
    echo "Run echo 'devuan ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
    echo "For future password prompt write devuan"
}

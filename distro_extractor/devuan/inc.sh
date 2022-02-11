#!/bin/bash

PM=deb
VM_USER=devuan
VM_PASS=$VM_USER

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Select Devuan Live Minimal (std)"
    echo "After boot"
    echo "Login as root:toor"
    echo "Set keytable if desirable (eg 'loadkeys cz-us-qwertz')"
    echo "Run 'dhclient'"
    echo "Run 'usermod -aG sudo $VM_USER'"
}

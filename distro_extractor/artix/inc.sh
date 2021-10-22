#!/bin/bash

VM_USER=artix

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Set keytable and start boot from CD/DVD/ISO"
    echo "After boot"
    echo "Login as artix:artix"
}

function boot_info_qemu() {
    echo "Run sudo -s"
    echo "Run ssh-keygen -A"
    echo "Run /bin/sshd"
    echo "For future password prompt write artix"
}

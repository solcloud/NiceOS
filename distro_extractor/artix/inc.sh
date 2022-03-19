#!/bin/bash

source distro_extractor/arch-based/inc.sh || exit 1

VM_USER=artix
VM_PASS=$VM_USER

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Set keytable and start boot from CD/DVD/ISO"
    echo "After boot"
    echo "Login as $VM_USER:$VM_PASS"
    echo "Run 'sudo -s'"
    echo "Run 'ssh-keygen -A'"
    echo "Run '/bin/sshd'"
}

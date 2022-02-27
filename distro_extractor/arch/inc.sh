#!/bin/bash

source distro_extractor/arch-based/inc.sh || exit 1

VM_USER=root
VM_PASS=arch

function boot_info() {
    echo "Go to $DISTRO window"
    echo "Select Arch Linux install medium"
    echo "After boot finished"
    echo "Run 'passwd'"
    echo "Type 'arch' and hit enter"
    echo "Type 'arch' and hit enter again to confirm"
}

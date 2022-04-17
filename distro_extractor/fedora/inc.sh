#!/bin/bash

PM=dnf
VM_USER=root
VM_PASS=''

function boot_info() {
    echo "Quickly go to $DISTRO window and press arrow down key"
    echo "Select 'Troubleshooting Fedora X' menu item and press enter"
    echo "Select 'Rescue a Fedora system' menu item and press enter"
    echo "Wait for boot to finish"
    echo "On prompt write '3' and hit enter (Skip to shell, or change tab)"
    echo "Please press enter to get a shell"
    echo "Run 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'"
    echo "Run 'echo PermitEmptyPasswords yes >> /etc/ssh/sshd_config'"
    echo "Run '/sbin/sshd'"
}

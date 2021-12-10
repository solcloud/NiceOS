// src https://github.com/kisslinux/init
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/reboot.h>

// This is a simple utility to instruct the kernel to shutdown
// or reboot the machine. This runs at the end of the shutdown
// process as an init-agnostic method of shutting down the system.
int main (int argc, char *argv[]) {
    if (geteuid() != 0) {
        printf("error: kpow must be run as root\n");
        return 1;
    }

    sync();

    switch (argc == 2 ? argv[1][0]: 0) {
        case 'p':
            reboot(RB_POWER_OFF);
            return 0;

        case 'r':
            reboot(RB_AUTOBOOT);
            return 0;

        default:
            printf("usage: kpow r[eboot]|p[oweroff]\n");
            return 1;
    }
}


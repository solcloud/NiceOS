// src https://github.com/kisslinux/init
#define _POSIX_C_SOURCE 200809L
#include <dirent.h>
#include <inttypes.h>
#include <unistd.h>
#include <signal.h>
#include <stdio.h>

// This is a simple 'killall5' alternative to remove the
// dependency on a rather unportable and "rare" tool for
// the purposes of shutting down the machine.
int main(int argc, char *argv[]) {
    struct dirent *ent;
    DIR *dir;
    int pid;
    int sig = SIGTERM;

    if (argc > 1) {
        sig = strtoimax(argv[1], 0, 10);
    }

    dir = opendir("/proc");

    if (!dir) {
        return 1;
    }

    kill(-1, SIGSTOP); // pause all process we can except PID:1

    while ((ent = readdir(dir))) { // for all directories inside /proc
        pid = strtoimax(ent->d_name, 0, 10); // try convert dir string name to base 10 number (PID)

        // Skip if
        if (pid < 2 || // error (not numeric dir, or pid1)
            pid == getpid() || // pid is current process
            getsid(pid) == getsid(0) || // session leader of current session
            getsid(pid) == 0) { // kernel session
            continue;
        }

        kill(pid, sig);
    }

    closedir(dir);
    kill(-1, SIGCONT); // resume all process we can except PID:1 and let them handle $sig

    return 0;
}

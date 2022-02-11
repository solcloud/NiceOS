#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building $TARGET"

mkdir -p "$TARGET"/{boot,dev,sys,home,mnt,proc,run,tmp,var} "$TARGET"/usr/{bin,lib} "$TARGET"/var/{empty,log}
chmod 0760 "$TARGET/init"

mkdir -p "$TARGET/usr/src"
git rev-parse HEAD > "$TARGET/usr/src/niceOS.hash"

{
    # Replace some /bin programs
    pushd "$TARGET/bin/"
        # Provide busybox if no 'sh' and no core counterparts is available
        if ([ ! -x "sh" ] || [ "busybox" == "$(readlink sh)" ]); then
            for util in $(./busybox --list); do
                ln -s busybox "$util" 2> /dev/null || true
            done
        fi

        # Overwrite some core utils
        ln -sf busybox login # bypass logind
        ln -sf busybox hostname # override net-tools version or /proc/sys/kernel/hostname symlink for more universal solution

        [ -x mcedit ] && { # mcedit if no vi
            ln -s mcedit vi || true
        }
        [ -f bash ] && { # bash pls
            ln -sf bash sh
        }
        rm -f init # we have own init
    popd
}

{
    # Fix some file permissions
    chmod -R o+rX,o-w "$TARGET/etc/"
    chmod -R o-r "$TARGET/etc/ssh/" || true
    chmod -R o+rX "$TARGET/usr/share/" || true
    chmod -R o-rwx "$TARGET/root/"

    # Add other read permission for text executable files inside bin
    chmod -R o-r "$TARGET/usr/bin/" 2> /dev/null || true
    for bin in $(find "$TARGET/usr/bin/" -type f -exec file {} \; | grep 'text executable' | grep -E -i -o -e "$TARGET/usr/bin/[-a-z0-9._+]+: " | sed 's/: //'); do
        chmod o+r "$bin"
    done
    chmod o+r "$TARGET/usr/bin/busybox"
}

{
    # Replace some $TARGET/usr files with our own build support
    pushd "$SUPPORT_BUILD"
        for dir in *; do
            pushd "$dir"
                ./build.sh
                DESTDIR="$TARGET/usr" ./install.sh
            popd
        done
    popd
}

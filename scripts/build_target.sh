#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building $TARGET"
mkdir -p "$TARGET"/{boot,dev,sys,home,mnt,proc,run,tmp,var} "$TARGET"/usr/{bin,lib} "$TARGET"/var/{empty,log}
chmod 0760 "$TARGET/init"

mkdir -p "$TARGET/usr/src"
git rev-parse HEAD > "$TARGET/usr/src/niceOS.hash"

# Replace some /bin programs
pushd "$TARGET/bin/"
    # Overwrite some core utils
    ln -s busybox clear &> /dev/null || true # everybody likes clear
    ln -sf busybox login # bypass logind
    ln -sf busybox hostname # override net-tools version or /proc/sys/kernel/hostname symlink for more universal solution

    [ -x mcedit ] && { # mcedit if no vi
        ln -s mcedit vi 2> /dev/null || true
    }
    [ -f bash ] && { # bash pls
        ln -sf bash sh
    }
    rm -f init # we have own init
popd


# Fix some file permissions
chmod -R o+rX,o-w "$TARGET/etc/"
chmod -R o-r "$TARGET/etc/ssh/" 2> /dev/null || true
chmod -R o+rX "$TARGET/usr/share/" 2> /dev/null || true
chmod -R o-rwx "$TARGET/root/"


# Add other read permission for text executable files inside bin
chmod -R o-r "$TARGET/usr/bin/" 2> /dev/null || true
for bin in $(find "$TARGET/usr/bin/" -type f -exec file {} \; | grep 'text executable' | grep -E -i -o -e "$TARGET/usr/bin/[-a-z0-9._+]+: " | sed 's/: //'); do
    chmod o+r "$bin"
done
chmod o+rx "$TARGET/usr/bin/busybox"
[ -f "$TARGET/bin/su" ] && [ ! -L "$TARGET/bin/su" ] && chmod u+s "$TARGET/bin/su" || true


# Replace some $TARGET/usr files with our own build support
pushd "$SUPPORT_BUILD"
    for dir in *; do
        pushd "$dir"
            ./build.sh
            DESTDIR="$TARGET/usr" ./install.sh
        popd
    done
popd

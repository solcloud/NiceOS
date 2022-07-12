#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building $TARGET"
mkdir -p "$TARGET"/{boot,dev,sys,home,mnt,proc,run,tmp,var} "$TARGET"/usr/{bin,lib} "$TARGET"/var/{empty,log}
chmod 0760 "$TARGET/init"

mkdir -p "$TARGET/usr/src"
git rev-parse HEAD > "$TARGET/usr/src/niceOS.hash" || true

# Provide some /bin programs
pushd "$TARGET/bin/"
    ln -s busybox clear &> /dev/null || true # everybody wants clear
    ln -sf busybox hostname # override net-tools version or /proc/sys/kernel/hostname symlink for more universal solution
popd


# Fix some file permissions
chmod -R o+rX,o-w "$TARGET/etc/"
chmod -R o-r "$TARGET/etc/ssh/" 2> /dev/null || true
chmod -R o+rX "$TARGET/usr/share/" 2> /dev/null || true
chmod -R o-rwx "$TARGET/root/"


# Replace some $TARGET/usr files with our own build support
pushd "$SUPPORT_BUILD"
    for dir in *; do
        pushd "$dir"
            ./build.sh
            DESTDIR="$TARGET/usr" ./install.sh
        popd
    done
popd

[ -x "$NICE_PRESET_PATH/check.sh" ] && "$NICE_PRESET_PATH/check.sh" || true

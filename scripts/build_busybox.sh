#!/bin/bash

set -e
source ./.config.sh || exit 1

echo "Building Busybox"
mkdir -p "$BUSYBOX_BUILD"
cd "$BUSYBOX_BUILD"

[ -d "$BUSYBOX_SRC" ] || {
    tar --checkpoint=200 -xf "$BUSYBOX" || dd "Missing busybox src $BUSYBOX - try run 'make download'"
    cd "$BUSYBOX_SRC"
    make distclean
}
cd "$BUSYBOX_SRC"

cp "$NICE_PRESET_PATH/busybox.config" '.config'
grep -q 'CONFIG_STATIC=y' '.config' || dd "CONFIG_STATIC=y is required for busybox"

if ! [ -r "/lib64/libcrypt.a" ] && (file /bin/busybox | grep 'statically linked'); then # arch removes static libcrypt
    notify "Using host static busybox"
    cp -f /bin/busybox "$BUSYBOX_SRC/busybox"
else
    make $MAKEFLAGS busybox
fi

mkdir -p "$TARGET/usr/bin"
cp -f "$BUSYBOX_SRC/busybox" "$TARGET/usr/bin/busybox"
chmod o+rx "$TARGET/usr/bin/busybox"

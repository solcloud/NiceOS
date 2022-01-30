#!/bin/bash

set -e
source ./.config.sh

# Linux
LINUX_MAJOR_VERSION=$(echo "$LINUX_VERSION" | grep -o -E '^[1-9]+')
[ -f "$LINUX" ] || wget -O "$LINUX" "https://cdn.kernel.org/pub/linux/kernel/v${LINUX_MAJOR_VERSION}.x/linux-${LINUX_VERSION}.tar.xz" || rm "$LINUX"

# Busybox
[ -f "$BUSYBOX" ] || wget -O "$BUSYBOX" "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2" || rm "$BUSYBOX"

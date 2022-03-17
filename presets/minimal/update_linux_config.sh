#!/bin/bash

set -e
source ./.config.sh || exit 1

cd "$LINUX_SRC"
make allnoconfig
./scripts/config --enable 'CONFIG_64BIT' --enable 'CONFIG_BLK_DEV_INITRD' --enable 'CONFIG_PRINTK' --enable 'CONFIG_BINFMT_ELF' --enable 'CONFIG_BINFMT_SCRIPT' --enable 'CONFIG_DEVTMPFS' --enable 'CONFIG_DEVTMPFS_MOUNT' --enable 'CONFIG_TTY' --enable 'CONFIG_SERIAL_8250' --enable 'CONFIG_SERIAL_8250_CONSOLE' --enable 'CONFIG_PROC_FS' --enable 'CONFIG_SYSFS'
cp '.config' "$NICE_PRESET_PATH/linux.config"

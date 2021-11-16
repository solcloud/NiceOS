#!/bin/bash

set -o pipefail

# //////// BASE PARAMS ///////////
export BASE="/data/src/nice"
export TARGET_USER=dan
export TARGET_GROUP=code
export MAKE_NUM_OF_THREATS='6'

export LINUX_VERSION='5.14.18'
export BUSYBOX_VERSION='1.34.1'

export QEMU_NPROC=1
export QEMU_RAM='4G'
export DISK_SIZE_GB=6
# ////////////////////////////////

export STORAGE=$BASE/storage
export OPT=$STORAGE/temp/dwn

export VIRTUAL_BOX_VMS_ROOT="$HOME/VirtualBox VMs"
export VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID=f8076108-303e-4ddb-9cfa-0fc5e81ef390
export VM_MOUNT_ROOT=/tmp/nice_vm_root

export MOUNT_PATH=$STORAGE/temp/mnt/nice_root
export BUILDS=$BASE/build
export TARGET=$BASE/target
export DISK_FILE="$STORAGE/sda.img"

export MAKEFLAGS="-j${MAKE_NUM_OF_THREATS}"
[ -z $ORIG_PATH ] && export ORIG_PATH=$PATH || true
export PATH=$ORIG_PATH
unset LD_LIBRARY_PATH

export LINUX="$OPT/linux-$LINUX_VERSION.tar.xz"
export LINUX_BUILD="$BUILDS/linux"
export LINUX_SRC=$LINUX_BUILD/linux-$LINUX_VERSION
export LINUX_COPY_SRC_TO_TARGET="0"

export BUSYBOX="$OPT/busybox-$BUSYBOX_VERSION.tar.bz2"
export BUSYBOX_BUILD="$BUILDS/busybox"
export BUSYBOX_SRC="$BUSYBOX_BUILD/busybox-$BUSYBOX_VERSION"

export INITRAMFS_BUILD=$BUILDS/initramfs
export SUPPORT_BUILD=$BUILDS/support
export NICE_PRESET_PATH="$BASE/presets/$NICE_PRESET"
export NICE_HAS_PRIMARY_DISK="1"
export NICE_HAS_SECONDARY_DISK="0"

if [ -z $NICE_PRESET ]; then
    echo "You need to specify target preset from $NICE_PRESET_PATH"
    echo "use \`export NICE_PRESET=minimal\` for example"
    exit 1
fi
export NICE_PRESET=$NICE_PRESET


function dd() {
	echo ${1:-'Error'}
	echo "Exiting"
	exit 201
}

function notify() {
    echo "$1"
    ls /bin/notify-send > /dev/null 2>& 1 && /bin/notify-send "${1:-'Alert'}" || true
}

if [ ! -f /bin/sudo ]; then
    function sudo() {
        COM="$@"
        printf "$(cat $BASE/_pass)" | su -c "$COM" r
    }
fi

function load_target_toolchain() {
    export PATH=$TARGET/usr/bin:$ORIG_PATH
    export LD_LIBRARY_PATH=$TARGET/usr/lib
}

[ -r "$NICE_PRESET_PATH/build_env.sh" ] && source "$NICE_PRESET_PATH/build_env.sh" || true

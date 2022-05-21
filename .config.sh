#!/bin/bash

set -o pipefail

# ////////////////////////////// BASE PARAMS /////////////////////////////////////
export BASE=$(pwd)
export TARGET_USER=$(id -u)
export TARGET_GROUP=$(id -g)

export MAKE_NUM_OF_THREADS=2
export QEMU_RAM='1G'
export QEMU_PROCESSOR_CORES=1
export DISK_SIZE_GB=1

# ///// Load user custom config.sh if exists that overrides default params
[ -r "$BASE/config.sh" ] && source "$BASE/config.sh"
# ////////////////////////////////////////////////////////////////////////////////

export STORAGE=${STORAGE:-"$BASE/storage"}
export BUILDS=${BUILDS:-"$STORAGE/build"}
export TARGET=${TARGET:-"$BASE/target"}
export OPT=$STORAGE/temp/dwn && mkdir -p "$OPT"

export VM_MOUNT_ROOT=${VM_MOUNT_ROOT:-'/tmp/nice_vm_root'}
export VIRTUAL_BOX_VMS_ROOT=${VIRTUAL_BOX_VMS_ROOT:-"$HOME/VirtualBox VMs"}
export VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID=${VIRTUAL_BOX_NICE_VIRTUAL_HDD_UUID:-'f8076108-303e-4ddb-9cfa-0fc5e81ef390'}
export MAKEFLAGS=${NICE_MAKE_FLAGS:-"-j${MAKE_NUM_OF_THREADS}"}

export MOUNT_PATH=$STORAGE/temp/mnt/nice_root
export DISK_FILE="$STORAGE/sda.img"
export NICE_HAS_PRIMARY_DISK="1"
export NICE_HAS_SECONDARY_DISK="0"
export INITRAMFS_BUILD=$BUILDS/initramfs
export SUPPORT_BUILD=$BUILDS/support

# Find out preset
NICE_PRESET_ROOT=${NICE_PRESET_ROOT:-"$BASE/presets"}
if [ -z $NICE_PRESET ]; then
    echo "You need to specify preset from '$NICE_PRESET_ROOT' folder"
    echo "use 'export NICE_PRESET=minimal' for example"
    exit 1
fi
export NICE_PRESET="$NICE_PRESET"
export NICE_PRESET_PATH="$NICE_PRESET_ROOT/$NICE_PRESET"
# Check for valid preset path
if ! [ -r "$NICE_PRESET_PATH" ]; then
    echo "Preset '$NICE_PRESET' not found in '$NICE_PRESET_ROOT"
    exit 1
fi
# Load custom preset variables if exists
[ -r "$NICE_PRESET_PATH/config.sh" ] && source "$NICE_PRESET_PATH/config.sh"


# Linux and busybox configs
[ -z $LINUX_VERSION ] && {
  echo "You need to specify LINUX_VERSION either globally ($BASE/config.sh) or in preset ($NICE_PRESET_PATH/config.sh)"
  exit 1
}
[ -z $BUSYBOX_VERSION ] && export BUSYBOX_VERSION='1.34.1'

export LINUX=${NICE_LINUX_ARCHIVE_PATH:-"$OPT/linux-$LINUX_VERSION.tar.xz"}
export LINUX_BUILD="$BUILDS/linux"
export LINUX_SRC=$LINUX_BUILD/linux-$LINUX_VERSION

export BUSYBOX="$OPT/busybox-$BUSYBOX_VERSION.tar.bz2"
export BUSYBOX_BUILD="$BUILDS/busybox"
export BUSYBOX_SRC="$BUSYBOX_BUILD/busybox-$BUSYBOX_VERSION"

###### Custom functions
function notify() {
    echo "$1"
    if which notify-send &> /dev/null; then
        notify-send "${1:-'Alert'}" || true
    fi
}

function dd() {
    notify "${1:-'Error'}"
    echo "Exiting"
    exit 201
}

if ! which sudo &> /dev/null; then
    [ -e /usr/src/niceOS.hash ] || dd "Sudo not found in PATH"
    function sudo() {
        COM="$@"
        #( echo "Sudo command:" && echo "$COM" && sleep 10 ) > /dev/stderr
        printf "$(cat $BASE/.pass)" | su -c "$COM" r
    }
fi

###### Checks
[ -w "$TARGET" ] || dd "Target folder '$TARGET' is not writable"

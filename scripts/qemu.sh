#!/bin/bash

set -e
source ./.config.sh || exit 1

OPTS=""
APPEND='mitigations=off'

# Usage
if [[ -n "$1" && "$1" = "gui" ]]; then
	OPTS="$OPTS"
elif [[ -n "$1" && "$1" = "cmd" ]]; then
	APPEND="$APPEND console=${QEMU_CONSOLE:-ttyS0} earlyprintk=serial"
	OPTS="$OPTS -nographic"
else
	dd "Usage $0 cmd|gui"
fi

# Check for KVM
if [ -r /dev/kvm ]; then
  [ "$NICE_QEMU_KVM" == "0" ] || OPTS="$OPTS -enable-kvm -cpu host"
else
  echo "Warning: '/dev/kvm' is not readable, fallbacking to emulation without KVM support"
fi

# Disks
NICE_QEMU_AHCI_SUPPORT=${NICE_QEMU_AHCI_SUPPORT:-1}
[ "$NICE_QEMU_AHCI_SUPPORT" == "1" ] && OPTS="$OPTS -device ahci,id=ahci" || true
if [ "$NICE_HAS_PRIMARY_DISK" = "1" ]; then
  OPTS="$OPTS -drive id=disk1,file=$STORAGE/sda.img,if=${NICE_PRIMARY_DISK_INTERFACE:-none},format=raw"
  [ "$NICE_QEMU_AHCI_SUPPORT" == "1" ] && OPTS="$OPTS -device ide-hd,drive=disk1,bus=ahci.1" || true
fi
if [[ "$NICE_HAS_SECONDARY_DISK" = "1" ]]; then
  if ! [ -r "$STORAGE/sdb.img" ]; then
    echo "Preset has secondary disk option enable but '$STORAGE/sdb.img' is not readable"
    dd "Create it for example by running 'qemu-img create -f raw $STORAGE/sdb.img 8G'"
  fi
  OPTS="$OPTS -drive id=disk2,file=$STORAGE/sdb.img,if=${NICE_SECONDARY_DISK_INTERFACE:-none},format=raw"
  [ "$NICE_QEMU_AHCI_SUPPORT" == "1" ] && OPTS="$OPTS -device ide-hd,drive=disk2,bus=ahci.2" || true
fi

# Run QEMU
qemu-system-${NICE_QEMU_ARCH:-x86_64} -kernel "${NICE_KERNEL:-$TARGET/boot/vmlinuz}" \
  -initrd "${NICE_INITRD:-$TARGET/boot/initrd}" \
  -append "${NICE_APPEND:-$APPEND}" \
  -usb \
  -device usb-tablet \
  -netdev user,id=net0,hostfwd=tcp::2201-:22 \
  -smp "$QEMU_PROCESSOR_CORES" \
  -m "$QEMU_RAM" $OPTS ${NICE_QEMU_EXTRA_OPTS:--net nic,model=e1000,netdev=net0}

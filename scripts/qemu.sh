#!/bin/bash

source ./.config.sh || exit 1

OPTS=""
APPEND='mitigations=off'

if [ -r /dev/kvm ]; then
  OPTS="$OPTS -enable-kvm -cpu host"
else
  echo "Warning: '/dev/kvm' is not readable, fallbacking to emulation without KVM support"
fi

if [[ -n "$1" && "$1" = "gui" ]]; then
	OPTS="$OPTS"
elif [[ -n "$1" && "$1" = "cmd" ]]; then
	APPEND="$APPEND console=ttyS0 earlyprintk=serial"
	OPTS="$OPTS -nographic"
else
	dd "Usage $0 cmd|gui [T for $BASE/target/boot | B* for $BUILDS ]"
fi

INITRD="$BUILDS/initramfs.cpio.gz"
KERNEL="$LINUX_SRC/arch/x86_64/boot/bzImage"
if [[ -n "$2" && "$2" = "T" ]]; then
	KERNEL="$TARGET/boot/vmlinuz"
	INITRD="$TARGET/boot/initrd"
fi


if [ "$NICE_HAS_PRIMARY_DISK" = "1" ]; then
  OPTS="$OPTS -drive id=disk1,file=$STORAGE/sda.img,if=none,format=raw -device ide-hd,drive=disk1,bus=ahci.1"
fi
if [[ "$NICE_HAS_SECONDARY_DISK" = "1" ]]; then
  if ! [ -r "$STORAGE/sdb.img" ]; then
    echo "Preset has secondary disk option enable but '$STORAGE/sdb.img' is not readable"
    dd "Create it for example by running 'qemu-img create -f raw $STORAGE/sdb.img 8G'"
  fi
  OPTS="$OPTS -drive id=disk2,file=$STORAGE/sdb.img,if=none,format=raw -device ide-hd,drive=disk2,bus=ahci.2"
fi


qemu-system-x86_64 -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -append "$APPEND" \
  -device ahci,id=ahci \
  -usb \
  -device usb-tablet \
  -device intel-hda -device hda-duplex \
  -net user,hostfwd=tcp::2201-:22 -net nic \
  -smp "$QEMU_PROCESSOR_CORES" \
  -m "$QEMU_RAM" $OPTS

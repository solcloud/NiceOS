#!/bin/bash

source ./.config.sh || exit 1

function boot_info() {
    echo -n ""
}
source "$BASE/distro_extractor/$DISTRO/inc.sh" || dd "File '$BASE/distro_extractor/$DISTRO/inc.sh' cannot be sourced"

function ssh_install() {
    [ -r "$NICE_PRESET_PATH/packages.${PM}.txt" ] || dd "No packages list for your preset and $DISTRO found ($NICE_PRESET_PATH/packages.${PM}.txt)"
    echo "For password prompt write $VM_PASS"
    scp -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P "$2" "$BASE/distro_extractor/$DISTRO/install.sh" "$NICE_PRESET_PATH/packages.${PM}.txt" "$VM_USER@$1:/tmp/"
    echo "${VM_PASS:-''}" | ssh -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$VM_USER@$1" -p "$2" 'sudo --stdin bash /tmp/install.sh'
}

function host_shell_wait() {
    echo "Welcome back to user host shell"
    echo "Waiting for virtual machine to shutdown for max 60sec"
    for i in {1..10}
    do
        sleep 6
        ps auxf | grep -- "$1" | grep -v grep > /dev/null || break
        echo "Waiting..."
    done
}

function from_qemu() {
    qemu-img create -f raw "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH" "${DISK_SIZE_GB}G"
    qemu-system-x86_64 \
        -cdrom "$DISTRO_ISO" -drive file="$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH",format=raw,cache=unsafe -m "$QEMU_RAM" \
        -net user,hostfwd=tcp::2201-:22 -net nic -enable-kvm -cpu host -smp "$QEMU_PROCESSOR_CORES" &

    boot_info
    echo "Press enter here"
    read

    ssh_install localhost 2201
    host_shell_wait "-cdrom $DISTRO_ISO"
}

function from_virtualbox() {
    VIRTUAL_BOX_VM_ROOT="$VIRTUAL_BOX_VMS_ROOT/nice_$DISTRO"
    echo "Startup virtual machine named 'nice_$DISTRO' ideally saved at '$VIRTUAL_BOX_VMS_ROOT'"
    echo "with one VDI hard disk connected (${DISK_SIZE_GB}GB) called 'nice_$DISTRO.vdi' at path '$VIRTUAL_BOX_VM_ROOT/nice_$DISTRO.vdi'"
    echo "with distribution installation CD connected"
    echo "with one bridged adapter network enabled"
    boot_info

    echo "Run ip addr | grep eth0 | grep inet"
    echo "Type here local ip address of bridge network eth0 (inet brd) and hit enter"
    read IP_ADDRESS
    echo "$IP_ADDRESS"

    ssh_install "$IP_ADDRESS" 22
    host_shell_wait "comment nice_$DISTRO"

    [ -r "$VIRTUAL_BOX_VM_ROOT/nice_$DISTRO.vdi" ] || dd "Cannot find VDI '$VIRTUAL_BOX_VM_ROOT/nice_$DISTRO.vdi'"
    echo "Extracting virtual disk image"
    VBoxManage clonehd --format RAW "$VIRTUAL_BOX_VM_ROOT/nice_$DISTRO.vdi" "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH"
}

rm -f "$NICE_EXTRACT_DISTRO_HDD_IMAGE_PATH"
if [[ "$HYPERVISOR" == "qemu" ]]; then
    from_qemu
elif [[ "$HYPERVISOR" == "virtualbox" ]]; then
    from_virtualbox
else
    echo "No valid HYPERVISOR found. Expecting QEMU or VirtualBox (VBoxManage at least) providers"
    dd "Make sure you have at least one HYPERVISOR installed in PATH"
fi

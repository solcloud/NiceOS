#!/bin/bash

source ./_config.sh

if [ -z $DISTRO ]; then
    echo "You need to specify extracting distribution from $BASE/distro_extractor, use one of"
    ls "$BASE/distro_extractor" | xargs | sed 's/ / OR /g'
    echo "use \`export DISTRO=artix\` for example"
    exit 1
fi
if [ -z $DISTRO_ISO ]; then
    echo "You need to specify distribution install iso path"
    echo "use \`export DISTRO_ISO=/data/dwn/artix-base-openrc-20210426-x86_64.iso\` for example"
    echo " or "
    echo "use \`export DISTRO_ISO=/data/dwn/devuan_chimaera_4.0.0_amd64_minimal-live.iso\` for example"
    echo " ... "
    exit 1
fi

VIRTUAL_BOX_VM_ROOT="$VIRTUAL_BOX_VMS_ROOT/$DISTRO"

function boot_info_qemu() {
    echo "For future password prompt write $VM_PASS"
}

source "$BASE/distro_extractor/$DISTRO/inc.sh" || exit

function ssh_install() {
    [ -r "$NICE_PRESET_PATH/packages.${PM}.txt" ] || dd "No packages list for your preset and $DISTRO found ($NICE_PRESET_PATH/packages.${PM}.txt)"
    scp -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $2 $BASE/distro_extractor/$DISTRO/install.sh $NICE_PRESET_PATH/packages.${PM}.txt $VM_USER@$1:/tmp/
    echo "${VM_PASS:-''}" | ssh -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $VM_USER@$1 -p $2 'sudo --stdin bash /tmp/install.sh'
}


function from_qemu() {
    cd "$OPT"
    rm -f 'distro.img'
    qemu-img create -f raw 'distro.img' 8G
    qemu-system-x86_64 \
        -cdrom "$DISTRO_ISO" \
        -drive file='distro.img',format=raw \
        -m $QEMU_RAM -enable-kvm -cpu host -smp 1 -net user,hostfwd=tcp::2201-:22 -net nic &

    boot_info
    boot_info_qemu

    echo "If all done press enter here"
    read WAIT

    ssh_install localhost 2201

    echo "Welcome back to user host shell"
    echo "Waiting for virtual machine to shutdown for max 60sec"
    for i in {1..20}
    do
        sleep 3
        echo "Waiting..."
        ps auxf | grep -- "-cdrom $DISTRO_ISO" | grep -v grep > /dev/null || break
    done
}

function from_virtualbox() {

    echo "Startup virtual machine named '$DISTRO' saved at $VIRTUAL_BOX_VM_ROOT"
    echo "with distribution installation CD connected"
    echo "one hard disk connected (min 8GB), one bridged adapter network enabled"
    boot_info
    echo "Run ip a | grep eth0 | grep inet"

    echo "Type here local ip address of bridge network eth0 (inet brd) and hit enter"
    read IP_ADDRESS
    echo $IP_ADDRESS

    ssh_install $IP_ADDRESS 22

    echo "Welcome back to user host shell"
    echo "Waiting for virtual machine to shutdown for max 60sec"
    for i in {1..20}
    do
        sleep 3
        echo "Waiting..."
        ps auxf | grep "comment $DISTRO" | grep -v grep > /dev/null || break
    done

    cd "$VIRTUAL_BOX_VM_ROOT" || dd "Cannot open '$VIRTUAL_BOX_VM_ROOT'"
    echo "Extracting virtual disk to distro.img"
    rm distro.img
    VBoxManage clonehd --format RAW "${DISTRO}.vdi" distro.img
}

function mount_vm_disk_to_tmp() {
    notify "We need sudo for mounting"

    sudo umount $VM_MOUNT_ROOT/ 2> /dev/null
    LOOP=$(sudo losetup --nooverlap --show -f -P distro.img)
    sudo rm -rf $VM_MOUNT_ROOT/
    mkdir $VM_MOUNT_ROOT/
    sudo mount $LOOP $VM_MOUNT_ROOT/
    echo "Mount VM hdd loop $LOOP at $VM_MOUNT_ROOT"
}

function copy_to_nice_target() {

    echo "Copying distro files to $TARGET"

    mount_vm_disk_to_tmp

    # Fill target dir
    notify "We need sudo for target copy"

    echo "Filling $TARGET directory"
    echo "Coping usr/ directory"
    rm -rf $TARGET/usr/
    sudo cp -a $VM_MOUNT_ROOT/usr/ $TARGET/

    echo "Coping var/ directory"
    rm -rf $TARGET/var/
    sudo cp -a $VM_MOUNT_ROOT/var/ $TARGET/var/

    if [ -r $VM_MOUNT_ROOT/etc/fonts/ ]; then
        echo "Coping fonts configs"
        rm -rf $TARGET/etc/fonts/
        sudo mkdir -p $TARGET/etc/
        sudo cp -a $VM_MOUNT_ROOT/etc/fonts/ $TARGET/etc/
    fi

    echo "Coping udev rules"
    sudo cp $VM_MOUNT_ROOT/usr/lib/udev/rules.d/* $TARGET/etc/udev/rules.d/

    echo "Changig ownership of $TARGET recursively to $TARGET_USER:$TARGET_GROUP"
    sudo chown -R $TARGET_USER:$TARGET_GROUP $TARGET
    rm -rf $TARGET/usr/lib/udev/rules.d/

    sync
    sudo sync
    echo "Done, checking dirty files"
    cd $BASE
    git restore target/var/run target/usr/share/mc/mc.ini
    git checkout target/var/run target/usr/share/mc/mc.ini
    git status

}

if [[ -n "$1" && "$1" = "virtualbox" ]]; then
    from_virtualbox
else
    from_qemu
fi
copy_to_nice_target

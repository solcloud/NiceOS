#!/bin/bash

source ./_config.sh

# ///////
ARTIX_ROOT=/tmp/artix_root
VIRTUAL_BOX_ARTIX_VIRTUAL_ROOT="$VIRTUAL_BOX_VMS_ROOT/artix"
# ///////

function ssh_install() {
	echo "For password prompt write artix"
	scp -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $2 $BASE/distro_extractor/install_artix.sh $NICE_PRESET_PATH/packages artix@$1:/tmp/
	ssh -o LogLevel=Error -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no artix@$1 -p $2 'sudo /bin/bash /tmp/install_artix.sh'

	echo "Welcome back to user host shell"
	echo "Waiting for virtual machine to shutdown for max 60sec"
}

function boot_info() {
	echo "Set keytable and start boot from CD/DVD/ISO"
	echo "After boot"
	echo "Login as artix:artix"
	echo "Run uname -a"
	echo "Make note which kernel version is running"
	echo "Run sudo -s"
	echo "Run ssh-keygen -A"
	echo "Run /bin/sshd"
}

function from_qemu() {
	cd "$OPT"
	rm -f 'artix.img'
	qemu-img create -f raw 'artix.img' 8G
	qemu-system-x86_64 \
		-cdrom "$ARTIX_ISO" \
		-drive file='artix.img',format=raw \
		-m 4G -enable-kvm -cpu host -smp 1 -net user,hostfwd=tcp::2201-:22 -net nic &
	echo "Go to artix qemu window"
	boot_info
	echo "If all done press enter here"
	read WAIT

	ssh_install localhost 2201
	for i in {1..20}
	do
		sleep 3
		echo "Waiting..."
		ps auxf | grep -- "-cdrom $ARTIX_ISO" | grep -v grep > /dev/null || break
	done
}

function from_virtualbox() {

	echo "Startup virtual machine named 'artix' saved at $VIRTUAL_BOX_ARTIX_VIRTUAL_ROOT"
	echo "with Artix linux installation CD connected"
	echo "one hard disk connected (min 8GB), one bridged adapter network enabled"
	boot_info
	echo "Run ip a | grep eth0 | grep inet"

	echo "Type here local ip address of bridge network eth0 (inet brd) and hit enter"
	read IP_ADDRESS
	echo $IP_ADDRESS

	ssh_install $IP_ADDRESS 22
	for i in {1..20}
	do
		sleep 3
		echo "Waiting..."
		ps auxf | grep 'comment artix' | grep -v grep > /dev/null || break
	done

	cd "$VIRTUAL_BOX_ARTIX_VIRTUAL_ROOT" || dd "Cannot open '$VIRTUAL_BOX_ARTIX_VIRTUAL_ROOT'"
	echo "Extracting virtual disk to artix.img"
	rm artix.img
	VBoxManage clonehd --format RAW artix.vdi artix.img
}

function mount_artix_to_tmp() {
	notify "We need sudo for mounting"

	sudo umount $ARTIX_ROOT/ 2> /dev/null
	LOOP=$(sudo losetup --nooverlap --show -f -P artix.img)
	sudo rm -rf $ARTIX_ROOT/
	mkdir $ARTIX_ROOT/
	sudo mount $LOOP $ARTIX_ROOT/
	echo "Mount artix hdd loop $LOOP at $ARTIX_ROOT"
}

function copy_to_nice_target() {

	echo "Coping artix files to $TARGET"

	mount_artix_to_tmp

	# Fill target dir
	notify "We need sudo for target copy"

	echo "Filling $TARGET directory"
	echo "Coping usr/ directory"
	rm -rf $TARGET/usr/
	sudo cp -a $ARTIX_ROOT/usr/ $TARGET/

	echo "Coping pacman database"
	rm -rf $TARGET/var/
	sudo mkdir -p $TARGET/var/lib/
	sudo cp -a $ARTIX_ROOT/var/lib/pacman/ $TARGET/var/lib/

	echo "Coping fonts configs"
	rm -rf $TARGET/etc/fonts/
	sudo mkdir -p $TARGET/etc/
	sudo cp -a $ARTIX_ROOT/etc/fonts/ $TARGET/etc/

	echo "Coping udev rules"
	sudo cp $ARTIX_ROOT/usr/lib/udev/rules.d/* $TARGET/etc/udev/rules.d/

	echo "Changig ownership of $TARGET recursively to $TARGET_USER:$TARGET_GROUP"
	sudo chown -R $TARGET_USER:$TARGET_GROUP $TARGET
	rm -rf $TARGET/usr/lib/udev/rules.d/

	sync
	sudo sync
	echo "Done, checking dirty files"
	cd $BASE
	git checkout target/var/run target/usr/share/mc/mc.ini
	git status

}

if [[ -n "$1" && "$1" = "virtualbox" ]]; then
	from_virtualbox
else
	from_qemu
fi
copy_to_nice_target

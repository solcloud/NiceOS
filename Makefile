.PHONY: target build build_%

all:
	@echo "make build|linux|busybox|initrd|target|ssh|sync|download|up|extract|vbox|cmd|gui"

extract:
	./ssh_install.sh

vbox:
	./vbox_disk_generate.sh

cmd:
	./qemu.sh cmd

gui:
	./qemu.sh gui

sync:
	./sync.sh

download:
	./download.sh

up:
	./sync.sh && ./qemu.sh cmd

target:
	./build_target.sh

build:
	./build.sh

ssh:
	@ssh -p 2201 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=Error r@localhost

%:
	"./build_${*}.sh"

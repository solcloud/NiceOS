.PHONY: target build build_%

all:
	@echo "make build|linux|busybox|initrd|target|ssh|sync|download|up|extract|vbox|cmd|gui"

extract:
	./scripts/extract_from_vm.sh && ./scripts/extract.sh

vbox:
	./scripts/vbox_disk_generate.sh

cmd:
	./scripts/qemu.sh cmd

gui:
	./scripts/qemu.sh gui

sync:
	./scripts/sync.sh

check:
	./scripts/check.sh

download:
	./scripts/download.sh

up:
	./scripts/sync.sh && ./scripts/qemu.sh cmd

target:
	./scripts/build_target.sh

clean:
	rm -rf target/ && git checkout target

build:
	./scripts/build.sh

test:
	./scripts/run_tests.sh

ssh:
	@ssh -p 2201 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=Error r@localhost

%:
	"./scripts/build_${*}.sh"

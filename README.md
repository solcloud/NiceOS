# NiceOS

Operating system with vanilla Linux kernel for advanced users who want to take full control of their system. You can do it, try it and make NiceOS your last Linux distribution ever!

[![Tests](https://github.com/solcloud/NiceOS/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/solcloud/NiceOS/actions/workflows/test.yml) [![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/playlist?list=PL6McYun7ERj4ZfT3DPlDtbWWIUaYXphrh) [![Linux](https://img.shields.io/badge/Linux-ffd133?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/) [![Bash](https://img.shields.io/badge/Shell_Script-121011?style=flat&logo=gnu-bash&logoColor=white)](scripts/)

## Minimal example

You can watch me building minimal preset on [YouTube](https://youtu.be/H09xbSGKjZw) ▶️

```bash
mkdir -p /data/src/nice # recommend folder with few spare gigs
git clone 'https://github.com/solcloud/NiceOS' /data/src/nice
cd /data/src/nice
$EDITOR .config.sh # read and add overrides inside config.sh if necessary
export NICE_PRESET=minimal # presets by default lives inside presets/ folder
make download # download Linux and BusyBox compressed releases
make build # for multicore use MAKE_NUM_OF_THREADS for speedup
make cmd # or make gui , qemu cmd quit shortcut 'Ctrl-a x'
```

For more presets look at [presets](presets/) folder, there is _base_ as a starting template and few my personal presets

## Promo

Everybody likes screenshots right 🙂 here is my 👻

![screenshot](https://user-images.githubusercontent.com/74121353/145203880-60802202-f278-46cc-bf20-7b0189b25b97.png)

## Advance example

Building my main desktop system - _Ghost_ 👻 with binaries extracted from Artix (Pᗣᗧ•••MᗣN)

You can watch me building ghost preset on [YouTube](https://youtu.be/SNuNFt7kSIE) ▶️

```bash
export NICE_PRESET=ghost
DISTRO=artix DISTRO_ISO=/data/dwn/artix-base-openrc-20220123-x86_64.iso make extract
make build
make gui
```

For extracting binaries from different distribution, just read [supported distributions](distro_extractor/README.md). We virtually provide extract recipes for every Linux distro ever made 😉. You just need to pick **one** that suits your preset best. For example, if you prefer _Devuan_ binaries over _Artix_ just use something like `DISTRO=devuan DISTRO_ISO=/path/to/devuan_chimaera_4.0.0_amd64_minimal-live.iso make extract` instead.

After successful `make build` you have a raw disk image file in `storage/sda.img` that you can _burn_ to real disk and boot from it or use `make gui` to run that image in _QEMU_ virtual emulator. If you do not want to use _QEMU_, you can run `make vbox` which will convert raw image to virtual disk image file (_.vdi_), that can be used in _VirtualBox_ for example. [Windows video](https://youtu.be/1cmmtuIoW7o) ▶

## User's config

For overwriting default config variables you can use git ignored `config.sh` file at project root, eg:

```bash
$ cat config.sh
export QEMU_RAM=3G
export TARGET_GROUP=code
export MAKE_NUM_OF_THREADS=6
```

## User's presets

If you have own presets in different folder than default [presets](presets/) folder, you can use `NICE_PRESET_ROOT` variable, eg:

```bash
export NICE_PRESET_ROOT=/home/me/nice/my_presets
# or use config.sh file
echo 'export NICE_PRESET_ROOT=/home/me/nice/my_presets' >> config.sh

export NICE_PRESET=my_custom_preset
make build
```

If you publish your presets to _GitHub_, do not forget to use [niceos](https://github.com/topics/niceos) tag on your repository. [Raspberry Pi video](https://youtu.be/3LGnqtkq2Ak) ▶

## Build dependencies

For debian based system you will probably need these packages:

```bash
sudo apt install git make gcc rsync bison flex cpio bc libelf-dev gawk fdisk wget lbzip2 xz-utils dosfstools libssl-dev libncurses-dev # required
sudo apt install qemu-system-gui qemu-utils # optional (for running and extracting in QEMU emulator)
```

If you are on **Arch Linux** and _BusyBox_ build failed with error `cannot find -lcrypt` than see [#8](https://github.com/solcloud/NiceOS/issues/8#issuecomment-1107801317) for solutions.

## Cross compiling

_NiceOS_ supports cross compiling using standard _Linux_ cross compile options using _ARCH_ and _CROSS_COMPILE_ environment variables. For example for arm64:

```bash
export ARCH=arm64
export CROSS_COMPILE='aarch64-linux-gnu-'
make build
```

[Here is example preset config](https://github.com/solcloud/nice-presets/blob/master/presets/raspi3b/config.sh) for _Raspberry Pi 3 Model B_.

# NiceOS

Operating system with vanilla Linux kernel for users who wants to take full control of their system. You can do it, try it!

[![Run tests](https://github.com/solcloud/NiceOS/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/solcloud/NiceOS/actions/workflows/test.yml)

## Minimal example

You can watch me building minimal preset on [youtube](https://youtu.be/4CH8b0HnIu8) ▶️

```bash
mkdir -p /data/src/nice # recommend HDD folder with few spare gigs
git clone 'https://github.com/solcloud/NiceOS' /data/src/nice
cd /data/src/nice
$EDITOR .config.sh # read carefully and make modifications inside config.sh
export NICE_PRESET=minimal # presets by default lives inside presets/ folder
make download # download linux and busybox compressed releases
make build
make cmd # or make gui , qemu cmd quit shortcut 'Ctrl-a x'
```

For more presets look at [presets](presets/) folder, there is _base_ as a starting template and few my personal presets

## Promo

Everybody likes screenshots right 🙂 here is my 👻

![screenshot](https://user-images.githubusercontent.com/74121353/145203880-60802202-f278-46cc-bf20-7b0189b25b97.png)

## Advance example

Building my main desktop system - _Ghost_ 👻 with binaries extracted from artix (Pᗣᗧ•••MᗣN)

You can watch me building ghost preset on [youtube](https://youtu.be/SNuNFt7kSIE) ▶️

```bash
export NICE_PRESET=ghost
DISTRO=artix DISTRO_ISO=/data/dwn/artix-base-openrc-20210726-x86_64.iso make extract
make build
make gui
```

For extracting binaries from other distribution just look at [distro_extractor](distro_extractor/) folder. We virtually provide extract recipes for every linux distro ever made 😉 For example if you prefer _debian_ binaries over _arch_ just use something like `DISTRO=devuan DISTRO_ISO=/path/to/devuan_chimaera_4.0.0_amd64_minimal-live.iso make extract`

## User's config

For overwriting default config variables you can use git ignored `config.sh` file at project root, eg:

```bash
$ cat config.sh
export QEMU_RAM='3G'
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

## Build dependencies

For debian system you will probably need these packages

```bash
sudo apt install git make gcc rsync bison flex cpio bc libelf-dev gawk fdisk wget lbzip2 xz-utils dosfstools libssl-dev libncurses-dev # required
sudo apt install qemu-system-gui qemu-utils # optional (for running and extracting in QEMU emulator)
```

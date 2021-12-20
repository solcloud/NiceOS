# NiceOS

A minimal example

```bash
mkdir -p /data/src/nice # recommend hdd folder with few spare gigs
git clone 'https://github.com/solcloud/NiceOS' /data/src/nice
cd /data/src/nice
$EDITOR _config.sh # read carefully and make modifications
export NICE_PRESET=minimal # presets by default lives inside presets/ folder
make download # download linux and busybox
make build
make cmd # or make gui , qemu cmd quit shortcut 'Ctrl-a x'
```

For more presets look at _presets/_ folder, there is _base_ preset and few my personal presets.

Advanced example - bulding my main desktop system - _Ghost_ with binaries extracted from artix (pacman)

```bash
cd /data/src/nice
export NICE_PRESET=ghost
DISTRO=artix DISTRO_ISO=/data/dwn/artix-base-openrc-20210426-x86_64.iso make extract
make build
make gui
```

## Promo
Everybody likes screenshots right 🙂 here is my 👻

![screenshot](https://user-images.githubusercontent.com/74121353/145203880-60802202-f278-46cc-bf20-7b0189b25b97.png)

## User's presets

If you have own presets in different folder than default _presets/_ folder, you can use `NICE_PRESET_ROOT` variable, eg:

```bash
export NICE_PRESET_ROOT=/home/me/nice/my_presets
export NICE_PRESET=my_custom_preset
make build
```

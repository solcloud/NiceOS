# NiceOS

A minimal example

```bash
mkdir -p /data/src/nice # recommend hdd folder with few spare gigs
git clone 'https://github.com/solcloud/NiceOS' /data/src/nice
cd /data/src/nice
$EDITOR _config.sh # read carefully and do modifications
export NICE_PRESET=minimal # presets live inside presets/ folder
make download # download linux and busybox
make build
make cmd # or make gui , qemu cmd quit shortcut 'Ctr-A x'
```

For more presets look at _presets/_ folder, there is _base_ preset and few my personal presets.

Advanced example - bulding my main desktop system - _Ghost_ using binaries from artix

```bash
cd /data/src/nice
export NICE_PRESET=ghost
DISTRO=artix DISTRO_ISO=/data/dwn/artix-base-openrc-20210426-x86_64.iso make extract
make build
make gui
```

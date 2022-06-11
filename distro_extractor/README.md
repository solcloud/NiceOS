## Extracting packages from other distributions 🚀

NiceOS do not provide package manager™. Instead, it uses other distributions package managers. You just need to choose **one** distribution that you like the most and use suitable extract method.

Currently, we support **3** extract methods:
- Virtual machine (**vm**)
  - **our recommended method for extracting**
  - you need virtual machine provider (_QEMU_ or _VirtualBox_) and distribution installation _ISO_
- Root file system (**rfs**)
  - installing by extracting distribution _rootfs_ into temp folder and perform _chroot_ install there 
- Debootstrap (**deb**)
  - for debian based distributions using _debootstrap_ binary

## Supported distributions ✔️

NiceOS support out of the box these distributions (alphabetical order):

---
**🛈 NOTE:**
Always check firstly for the latest version for your architecture and desired flavor on distribution homepage and use your specific version instead of example one.
Also, many distributions provide mirrors at different geographical places and URLs - try to use the closest and the fastest mirror for you. And always check downloaded files signature.

---


- **Arch** (https://archlinux.org/)
  - vm: `DISTRO=arch DISTRO_ISO=/path/to/archlinux-2022.02.01-x86_64.iso make extract`
  - rfs: `DISTRO=arch DISTRO_ROOTFS=/path/to/archlinux-bootstrap-2022.02.01-x86_64.tar.gz make extract`
- **Artix** (https://artixlinux.org/)
  - vm: `DISTRO=artix DISTRO_ISO=/path/to/artix-base-openrc-20220123-x86_64.iso make extract`
- **Debian** (https://www.debian.org/)
  - deb: `DEBOOTSTRAP_SUITE=stable DEBOOTSTRAP_MIRROR='https://deb.debian.org/debian/' make extract`
- **Devuan** (https://www.devuan.org/)
  - vm: `DISTRO=devuan DISTRO_ISO=/path/to/devuan_chimaera_4.0.0_amd64_minimal-live.iso make extract`
  - deb: `DEBOOTSTRAP_SUITE=stable DEBOOTSTRAP_MIRROR='https://packages.devuan.org/merged' make extract`
- **Fedora** (https://getfedora.org/)
  - vm: `DISTRO=fedora DISTRO_ISO=/path/to/Fedora-Server-netinst-x86_64-35-1.2.iso make extract`
- **Linux Mint** (https://www.linuxmint.com/)
  - deb: `DEBOOTSTRAP_SUITE=una DEBOOTSTRAP_SCRIPT=stable DEBOOTSTRAP_MIRROR='https://mirrors.edge.kernel.org/linuxmint-packages/' make extract`
- **MX Linux** (https://mxlinux.org/)
  - deb: `DEBOOTSTRAP_SUITE=bullseye DEBOOTSTRAP_SCRIPT=stable DEBOOTSTRAP_MIRROR='http://mxrepo.com/mx/repo/' make extract`
- **openSUSE** (https://www.opensuse.org/)
  - rfs: `DISTRO=openSUSE DISTRO_ROOTFS=/path/to/openSUSE-Leap-15.1-OpenStack-rootfs.x86_64.tar.xz make extract`
- **Pop!_OS** (https://system76.com/pop/)
  - deb: `DEBOOTSTRAP_SUITE=jammy DEBOOTSTRAP_SCRIPT=stable DEBOOTSTRAP_MIRROR='http://apt.pop-os.org/release' make extract`
- **Ubuntu** (https://ubuntu.com/)
  - rfs: `DISTRO=debian-based DISTRO_ROOTFS=/path/to/ubuntu-base-21.10-base-amd64.tar.gz make extract`
  - deb: `DEBOOTSTRAP_SUITE=jammy DEBOOTSTRAP_SCRIPT=stable DEBOOTSTRAP_MIRROR='http://archive.ubuntu.com/ubuntu' make extract`
- **Void** (https://voidlinux.org/)
  - vm: `DISTRO=void DISTRO_ISO=/path/to/void-live-x86_64-20210930.iso make extract`
  - rfs: `DISTRO=void DISTRO_ROOTFS=/path/to/void-x86_64-ROOTFS-20210930.tar.xz make extract`


_If you are missing your favorite distro or method here, just send pull request 😉_

#!/bin/bash

set -e
source ./_config.sh

echo "Building Linux"

mkdir -p "$TARGET/usr/src"
mkdir -p $LINUX_BUILD
cd $LINUX_BUILD

ls $LINUX_SRC > /dev/null || {
    tar -xvf $LINUX || dd "Missing linux kernel src $LINUX"
    cd $LINUX_SRC
    make mrproper
}
cd $LINUX_SRC

# Kernel build
cp $NICE_PRESET_PATH/linux.config .config
make olddefconfig # comment for interactive asking
make $MAKEFLAGS vmlinux bzImage

# Modules install
HAS_MODULES_SUPPORT=$(source ./.config ; [ "y" == "$CONFIG_MODULES" ] && echo "1" || echo "0")
if [ "$HAS_MODULES_SUPPORT" == "1" ]; then
    make $MAKEFLAGS modules
    make INSTALL_MOD_PATH=$TARGET/usr INSTALL_MOD_STRIP=1 modules_install
fi

# Headers install
make INSTALL_HDR_PATH=$TARGET/usr INSTALL_MOD_STRIP=1 headers_install

if [ "$LINUX_COPY_SRC_TO_TARGET" = "1" ]; then
    # Copying only required directories after modules_prepare is boring (what drivers/ are required universally for future expansion) and disk space is cheap, grab whole source
    rsync --archive --delete --chmod=o-rwx "$LINUX_SRC/" "$TARGET/usr/src/$LINUX_VERSION/"
    # Cleanup not needed files from kernel source
    pushd "$TARGET/usr/src/$LINUX_VERSION"
        #rm -rf ./Documentation/
        #rm -rf ./drivers/
    popd

    printf "
#!/bin/bash

if ! mount | grep 'on /boot'; then
    echo 'Mount /boot partition!'
    exit 1
fi

TARGET=''
LINUX_SRC=/usr/src/$LINUX_VERSION

cd \$LINUX_SRC

make $MAKEFLAGS vmlinux bzImage modules
make INSTALL_MOD_PATH=\$TARGET/usr INSTALL_MOD_STRIP=1 modules_install
make INSTALL_HDR_PATH=\$TARGET/usr INSTALL_MOD_STRIP=1 headers_install

cp -f \$LINUX_SRC/.config \$TARGET/boot/kernel.config
cp -f \$LINUX_SRC/System.map \$TARGET/boot/System.map
cp -f \$LINUX_SRC/arch/x86/boot/bzImage \$TARGET/boot/vmlinuz

" > "$TARGET/usr/src/$LINUX_VERSION/rebuild_and_reinstall.sh"
fi

# Update modules kernel src symlink
if [ "$LINUX_COPY_SRC_TO_TARGET" = "1" ] && [ "$HAS_MODULES_SUPPORT" == "1" ]; then
    pushd $TARGET/usr/lib/modules/$LINUX_VERSION/
        rm -f build source
        ln -s ../../../src/$LINUX_VERSION/ build
        ln -s ../../../src/$LINUX_VERSION/ source
    popd
fi

cp -f $LINUX_SRC/.config $TARGET/boot/kernel.config
cp -f $LINUX_SRC/System.map $TARGET/boot/System.map
cp -f $LINUX_SRC/arch/x86/boot/bzImage $TARGET/boot/vmlinuz

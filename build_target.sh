#!/bin/bash

set -e
source ./_config.sh

echo "Building $TARGET"

mkdir -p $TARGET/{boot,dev,sys,home,mnt,proc,run,tmp,var} $TARGET/usr/{bin,lib} $TARGET/var/log
chmod 0760 $TARGET/init

mkdir -p "$TARGET/usr/src"
git rev-parse HEAD > "$TARGET/usr/src/niceOS.hash"

{
    # Create some files
    pushd $TARGET
        mkdir -p var/empty/ # SSH expect empty folder for chrooting
        rm -rf var/empty/*
    popd
}


{
    # Replace some gnu utils with busybox
    pushd $TARGET/bin/
        # Provide busybox if no 'sh' a no core counterparts is available
        [ -f sh ] || for util in $(./busybox --list); do
            ln -s busybox $util 2> /dev/null || true
        done

        # Overwrite some core utils
        # Bypass logind
        ln -sf busybox login
        ln -f busybox hostname || true

        # Other
        ls mcedit 2> /dev/null && {
            ln -sf mcedit vi
            ln -sf mcedit vim
            ln -sf mcview pr
        } || true

        # Bash pls
        ls bash 2> /dev/null && {
            ln -sf bash sh
        }

        # Init specific stuff
        rm -f init
        rm -f initrc
        rm -f linuxrc

        # Unused utilities
        rm -f powertop
        rm -f whatis apropos accessdb
        rm -f addgnupghome applygnupgdefaults
        rm -f alsabat* alsa-info* alsa_delay
        rm -f arpd
        rm -f audisp* audit* augenrules aulast* last lastb lastlog aureport ausearch autrace auvirt
        rm -f avahi-* bshell bssh bvnc
        rm -f bashbug
        rm -f bd_*
        rm -f cec-*
        rm -f croco-*
        rm -f ctrlaltdel
        rm -f desktop-file-*
        rm -f elogind*
        rm -f fancontrol
        rm -f findssl.sh
    popd
}


{
    # Fix some file permissions
    chmod -R o+rX,o-w $TARGET/etc/
    chmod -R o+rX $TARGET/usr/share/

    # Other perm in /etc
    pushd $TARGET/etc/
        chmod o+r "shadow" # need for password verify without suid or daemon
        chmod -R o-r "ssh/"
    popd

    # Add other read permission for text executable files inside bin
    chmod -R o-r $TARGET/usr/bin/ 2> /dev/null || true
    for bin in $(find $TARGET/usr/bin/ -type f -exec file {} \; | grep 'text executable' | egrep -i -o -e "$TARGET/usr/bin/[-a-z0-9]+: " | sed 's/: //'); do
        chmod o+r $bin
    done

    chmod -R o-rwx $TARGET/root/
    [ $(find "$TARGET/bin/su" -type f) ] && chmod u+s "$TARGET/bin/su" || true
}


{
    # Replace some TARGET/usr files with our own build support
    pushd $SUPPORT_BUILD
        for dir in *; do
            pushd $dir
                make NICE_BASE=$BASE $MAKEFLAGS
                make NICE_BASE=$BASE DESTDIR="$TARGET/usr" install
            popd
        done
    popd
}


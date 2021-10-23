#!/bin/bash

set -e
source ./_config.sh

echo -n "Checking file permissions...."

# SUID and GUID
find $TARGET/ -type f -perm /4000 \
  | grep -v "^$TARGET/usr/bin/reboot\$" \
  | grep -v "^$TARGET/usr/bin/poweroff\$" \
  | grep -v "^$TARGET/usr/bin/su\$" \
  && dd 'Some unknown files has SUID!' || true
find $TARGET/ -type f -perm /2000 \
  | grep '' \
  && dd 'Some unknown files has GUID!' || true

# Files Other execute permission
find $TARGET/ -type f -perm -o=x \
  | grep -v "^$TARGET/usr/bin/" \
  | grep -v "^$TARGET/usr/lib/" \
  | grep -v "^$TARGET/etc/ssl/update-certdata.sh" \
  | grep -v "^$TARGET/etc/init/" \
  | grep -v "^$TARGET/etc/profile" \
  | grep -v "^$TARGET/etc/share/" \
  | grep -v "^$TARGET/usr/share/" \
  && dd "Some unknown files has Other execute permission" || true

echo "GOOD"

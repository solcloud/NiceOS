#!/bin/bash

set -e
source ./.config.sh || exit 1

# Replace some /bin programs
pushd "$TARGET/bin/"
    ln -sf busybox login # bypass logind
    [ -x mcedit ] && ln -s mcedit vi 2> /dev/null || true
    [ -f bash ] && ln -sf bash sh || true
    rm -f init*
popd

# Add other read permission for text executable files inside bin
chmod -R o-r "$TARGET/usr/bin/" 2> /dev/null || true
for bin in $(find "$TARGET/usr/bin/" -type f -exec file {} \; | grep 'text executable' | grep -E -i -o -e "$TARGET/usr/bin/[-a-z0-9._+]+: " | sed 's/: //'); do
    chmod o+r "$bin"
done
chmod o+rx "$TARGET/usr/bin/busybox"
[ -f "$TARGET/bin/su" ] && [ ! -L "$TARGET/bin/su" ] && chmod u+s "$TARGET/bin/su" || true


echo -n "Checking $TARGET files permissions...."

# SUID and GUID
find "$TARGET/" -type f -perm /4000 \
  | grep -v "^$TARGET/usr/bin/reboot\$" \
  | grep -v "^$TARGET/usr/bin/poweroff\$" \
  | grep -v "^$TARGET/usr/bin/su\$" \
  && dd 'Some unknown files has SUID' || true
find "$TARGET/" -type f -perm /2000 \
  | grep '' \
  && dd 'Some unknown files has GUID' || true

# Files Other execute permission
find "$TARGET/" -type f -perm -o=x \
  | grep -v "^$TARGET/usr/bin/" \
  | grep -v "^$TARGET/usr/lib/" \
  | grep -v "^$TARGET/usr/libexec/" \
  | grep -v "^$TARGET/etc/ssl/update-certdata.sh" \
  | grep -v "^$TARGET/etc/start_services.sh" \
  | grep -v "^$TARGET/etc/init/" \
  | grep -v "^$TARGET/etc/profile" \
  | grep -v "^$TARGET/etc/share/" \
  | grep -v "^$TARGET/usr/share/" \
  | grep -v "^$TARGET/var/lib/dpkg/" \
  && dd "Some unknown files has Other execute permission" || true

echo "GOOD"

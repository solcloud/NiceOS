#!/bin/sh

set -e

sleep 2
cat /usr/test.txt
test -e /usr/src/niceOS.hash
test -e /usr/src/rebuild_and_reinstall_linux.sh
test -e /etc/preset_sync_test
test -L /etc/preset_sync_symlink_test
test "$(hostname)" = 'base'
( echo "test /dev/stdout" > /dev/stdout ) > /dev/null
stat -c "%a" /bin/busybox | grep -q '7.5'
grep -q 'base' /etc/hosts


poweroff

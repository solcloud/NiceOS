#!/bin/sh

set -e

sleep 2
cat /usr/test.txt
test -e /usr/src/niceOS.hash
test -e /usr/src/rebuild_and_reinstall_linux.sh
test "$(hostname)" = 'base'
( echo "test /dev/stdout" > /dev/stdout ) > /dev/null


poweroff

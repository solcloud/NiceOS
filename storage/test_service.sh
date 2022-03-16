#!/bin/sh

set -e

sleep 2
cat /usr/test.txt
test "$(hostname)" = 'base'
( echo "test /dev/stdout" > /dev/stdout ) > /dev/null


poweroff

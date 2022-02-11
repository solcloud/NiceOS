#!/bin/sh

set -e

sleep 2
cat /usr/test.txt
test "$(hostname)" = 'base'


poweroff

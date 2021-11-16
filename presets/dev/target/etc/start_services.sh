#!/bin/sh

sleep 2 && sh -c 'while true; do dockerd --data-root /data/images > /dev/null 2>& 1; sleep 30; done' &
sleep 2 && sh -c 'while true; do /bin/sshd -D > /dev/null 2>& 1; sleep 30; done' &

wait
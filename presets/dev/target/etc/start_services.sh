#!/bin/sh

ln -s /proc/self/fd /dev/fd
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr

sleep 2 && sh -c 'while true; do dockerd --data-root /data/images > /dev/null 2>& 1; sleep 30; done' &
sleep 2 && sh -c 'while true; do /bin/sshd -D > /dev/null 2>& 1; sleep 30; done' &

wait

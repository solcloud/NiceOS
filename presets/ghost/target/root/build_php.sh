#!/bin/bash

set -e

PHP_VERSION='7.4.28'

git clone --depth=1 'https://github.com/php/php-src.git' -b "php-$PHP_VERSION" "src"
cd "src"

./buildconf --force
./configure \
    --prefix=/usr \
    --disable-all \
    --with-curl \
    --enable-json \
    --enable-mbstring \
    --disable-mbregex \
    --enable-filter \
    --enable-sockets

make -j $(nproc)
INSTALL_ROOT=target_root make install

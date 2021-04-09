#!/bin/bash

PHP_VERSION='7.4.20'
PHP="php-$PHP_VERSION.tar.xz"

[ ! -r "$PHP" ] && wget -O "$PHP" "https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz"

PHP_SRC="php-$PHP_VERSION"
[ ! -d $PHP_SRC ] && tar xf $PHP
cd php-$PHP_VERSION

[ ! -f config.log ] && ./configure \
    --prefix=/usr \
    --disable-all \
    --with-curl \
    --enable-json \
    --enable-mbstring \
    --disable-mbregex \
    --enable-filter \
    --enable-sockets && make -j $(nproc)

INSTALL_ROOT=target_root make install

sudo cp -a target_root/usr/include/php/ /usr/include/
sudo chown -R 0:0 /usr/include/php/
sudo cp target_root/usr/bin/php /usr/bin/php7
sudo chmod o+x /usr/bin/php7

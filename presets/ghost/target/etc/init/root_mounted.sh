#!/bin/sh

busybox loadkmap < /etc/share/kmap/cz-qwertz.map
#cryptsetup open $(findfs 'UUID=4e696365-486f-6d65-5061-72746974696f') home
#cryptsetup open $(findfs 'UUID=4e696365-436f-6465-5061-72746974696f') code

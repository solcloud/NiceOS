CFLAGS=-Werror -Wall -Wextra -static -Os
FILES=kpow reboot poweroff
CC=gcc
COMPILER=$(CROSS_COMPILE)$(CC)

all:
	$(COMPILER) $(CFLAGS) -o build/kpow src/kpow.c
	$(COMPILER) $(CFLAGS) -o build/reboot src/reboot.c
	$(COMPILER) $(CFLAGS) -o build/poweroff src/poweroff.c

clean:
	rm -f src/*.c.*
	cd build/ && rm -f $(FILES)

install:
	cd build/ && $(CROSS_COMPILE)strip $(FILES) && \
		cp --remove-destination -f $(FILES) $(DESTDIR)/bin/ && \
		chmod u+s,o+x $(DESTDIR)/bin/reboot && \
		chmod u+s,o+x $(DESTDIR)/bin/poweroff

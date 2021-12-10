CC=gcc
CFLAGS=-Werror -Wall -Wextra -static -s -fdata-sections -ffunction-sections -Wl,--gc-sections -Os
FILES=kpow reboot poweroff

all:
	$(CC) $(CFLAGS) -o build/kpow src/kpow.c
	$(CC) $(CFLAGS) -o build/reboot src/reboot.c
	$(CC) $(CFLAGS) -o build/poweroff src/poweroff.c

clean:
	rm -f src/*.c.*
	cd build/ && rm -f $(FILES)

install:
	cd build/ && strip $(FILES) && \
		cp --remove-destination -f $(FILES) $(DESTDIR)/bin/ && \
		chmod u+s,o+x $(DESTDIR)/bin/reboot && \
		chmod u+s,o+x $(DESTDIR)/bin/poweroff
	test -f $(DESTDIR)/bin/xdg-open || printf '#!/bin/sh\necho "$$1" | xclip -selection clipboard\n' > $(DESTDIR)/bin/xdg-open && chmod o+rx $(DESTDIR)/bin/xdg-open
	test -f $(DESTDIR)/bin/calendar || printf '#!/bin/sh\ncal -3\n' > $(DESTDIR)/bin/calendar && chmod o+rx $(DESTDIR)/bin/calendar

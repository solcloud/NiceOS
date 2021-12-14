all:
	@echo -n ''

install:
	test -f $(DESTDIR)/bin/xdg-open || printf '#!/bin/sh\necho "$$1" | xclip -selection clipboard\n' > $(DESTDIR)/bin/xdg-open && chmod o+rx $(DESTDIR)/bin/xdg-open
	test -f $(DESTDIR)/bin/calendar || printf '#!/bin/sh\ncal -3\n' > $(DESTDIR)/bin/calendar && chmod o+rx $(DESTDIR)/bin/calendar

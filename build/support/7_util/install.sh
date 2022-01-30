#!/bin/bash

[ -f "$DESTDIR/bin/xdg-open" ] || {
    cp "./src/xdg-open" "$DESTDIR/bin/xdg-open"
    chmod o+rx "$DESTDIR/bin/xdg-open"
}
[ -f "$DESTDIR/bin/calendar" ] || {
    cp "./src/calendar" "$DESTDIR/bin/calendar"
    chmod o+rx "$DESTDIR/bin/calendar"
}

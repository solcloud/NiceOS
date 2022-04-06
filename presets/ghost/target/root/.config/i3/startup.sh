#!/bin/bash

if [ "$(hostname)" = "ghost" ]; then
    xrandr --listmonitors | grep -q DP-0 && xrandr --output DP-0 --primary && xrandr --output DP-0 --mode 1920x1080 --rate 144.00
elif [ "$(hostname)" = "leti" ]; then
    if xrandr --listmonitors | grep -q -E '[+]\*?eDP-1'; then
        xrandr --listmonitors| grep -q 'Monitors: 1' && xrandr --output eDP-1 --mode 1368x768
        xrandr --listmonitors | grep -q -E '[+]\*?HDMI-1' && xrandr --output eDP-1 --off && xrandr --output HDMI-1 --primary
    fi
fi

#!/bin/bash

set -x

#xrandr --output eDP-1 --off
#echo 500 > /sys/class/backlight/intel_backlight/brightness

if [ "$(hostname)" = "ghost" ]; then
    xrandr --listmonitors | grep DP-0 && xrandr --output DP-0 --primary && xrandr --output DP-0 --mode 1920x1080 --rate 144.00
fi

if [ "$(hostname)" = "leti" ]; then
    if xrandr --listmonitors | grep -E '[+]\*?eDP-1'; then
        xrandr --listmonitors| grep 'Monitors: 1' && xrandr --output eDP-1 --mode 1368x768
        xrandr --listmonitors | grep -E '[+]\*?HDMI-1' && xrandr --output eDP-1 --off && xrandr --output HDMI-1 --primary # && i3-msg workspace 9 output eDP-1 && i3-msg workspace 1 output HDMI-1
    fi
fi

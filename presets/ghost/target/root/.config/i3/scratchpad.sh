#!/bin/sh

title_match="Terminal_main_scratchpad"
if xprop -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}') | grep -- "$title_match"; then
    i3-msg [title="$title_match"] scratchpad show
    exit 0
fi

i3-msg [title="$title_match" floating] move container to workspace current, focus && exit 0
i3-msg [title="$title_match" floating] scratchpad show && exit 0

$TERMINAL --title="$title_match" &
sleep 0.3s
i3-msg -- [title="$title_match"] move scratchpad, scratchpad show

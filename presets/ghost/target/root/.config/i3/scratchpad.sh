#!/bin/sh

title_match="Terminal_main_scratchpad"
if ps auxf | grep -- "--title $title_match" | grep -v 'grep' &> /dev/null; then
    i3-msg [title="$title_match"] scratchpad show
    exit 0
fi

$TERMINAL --title "$title_match" &
sleep 0.15s
i3-msg -- [title="$title_match"] move scratchpad
i3-msg -- [title="$title_match"] scratchpad show

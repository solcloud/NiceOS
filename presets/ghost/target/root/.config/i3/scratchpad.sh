#!/bin/sh

title_match="Terminal_main_scratchpad"
if i3-msg [title="$title_match"] scratchpad show; then
    exit 0
fi

$TERMINAL --title="$title_match" &
sleep 0.15s
i3-msg -- [title="$title_match"] move scratchpad
i3-msg -- [title="$title_match"] scratchpad show
i3-msg -- [title="$title_match"] border pixel 2, resize set 980px 400px, move down 370px

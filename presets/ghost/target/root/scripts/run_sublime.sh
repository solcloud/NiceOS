printf 'editor' | su -l -c "XDG_DESKTOP_DIR=/data/desk DISPLAY=$DISPLAY ~/sublime/sublime_text" editor && sleep 1 && i3-msg 'workspace 3'

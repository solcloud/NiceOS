printf 'editor' | su -l -c "umask 001 ; DISPLAY=$DISPLAY ~/sublime/sublime_text $1" editor

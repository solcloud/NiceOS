exec printf 'code' | su -l -c "export DISPLAY=$DISPLAY ; $TERMINAL --title Machine_Dev -e dev machine up" code

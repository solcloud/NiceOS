udevd --daemon 2> /dev/null
udevadm trigger --action=add --type=subsystems
udevadm trigger --action=add --type=devices
sleep 20 && udevadm control --exit &

depmod
echo "You may need to reboot for modules depmod effect or force loading"
echo "also you may need to rebuild kernel src at /usr/src/$(uname -r)/ using rebuild_and_reinstall.sh there"
echo "or even delete whole source and untar from archive if your build cc and libc is too different than running environment"
echo "Spawning shell so you can decide"
sh

echo "Enter root password"
passwd

echo 'cs_CZ.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
mkdir -p /var/cache/
fc-cache # create /var/cache/fontconfig
ldconfig --ignore-aux-cache # create /etc/ld.so.cache and /var/cache/ldconfig/aux-cache

fdisk -l
echo "Create additional partitions, mount it (/data, /home, /code) type exit when done"
sh
mkdir -p /data/{dwn,desk,store}

USERS="dan daniel firefox storm code editor"
for user in $USERS; do
    useradd -m -U -s /bin/bash $user && printf "$user\n$user" | passwd $user
    echo "" > "/home/$user/.bashrc"
    echo ". /etc/environment" >> "/home/$user/.bashrc"
    echo ". /etc/profile" >> "/home/$user/.bashrc"
    ln -sf "/home/$user/.bashrc" "/home/$user/.bash_profile"
done

for user in firefox; do
    usermod -aG audio $user
done
for user in dan; do
    usermod -aG tty,video,audio,input $user # Allow tty and Xorg (gpu,audio,input) login
    mkdir -p /home/$user/.config/
    cp -r /root/.config/{dunst,i3,i3status,mc,sakura,volumeicon} /home/$user/.config/
    cp /root/.xinitrc /home/$user/
    rm /home/$user/.bash_profile
    printf '
. ~/.bashrc

if [[ "$(tty)" = "/dev/tty1" ]]; then
    exec xinit
fi
' > /home/$user/.bash_profile
done

for user in dns; do
    useradd $user
    printf "$user\n$user" | passwd $user
done

for user in dan daniel storm editor dns; do
    usermod -aG code $user
done

usermod -u 7001 code
groupmod -g 7001 code

for user in $USERS; do
    chown -R $user:$user "/home/$user"
done

if lsmod | grep 'bochs'; then
    echo 'bindsym Mod1+t exec --no-startup-id $TERMINAL' >> /home/dan/.config/i3/config
fi

# Desktop entries
rm -rf /usr/local/share/*
pushd /usr/share/applications
    rm -rf *

    printf '[Desktop Entry]
Name=Firefox
Exec=/usr/share/applications/scripts/run_firefox.sh

Categories=Network
Terminal=false
StartupNotify=false
Type=Application
' > firefox.desktop

    printf '[Desktop Entry]
Name=PHPStorm
Exec=/usr/share/applications/scripts/run_storm.sh

Categories=Development
Terminal=false
StartupNotify=false
Type=Application
' > phpstorm.desktop

    printf '[Desktop Entry]
Name=SublimeText
Exec=/usr/share/applications/scripts/run_sublime.sh

Categories=Development
Terminal=false
StartupNotify=false
Type=Application
' > sublime.desktop

    printf '[Desktop Entry]
Name=MachineDev
Exec=/usr/share/applications/scripts/run_machine_dev.sh

Categories=Development
Terminal=false
StartupNotify=false
Type=Application
' > machine_dev.desktop

    printf '[Desktop Entry]
Name=Redshift
Exec=/bin/redshift -x -P && /bin/redshift -l 50.2104:15.8252 -o

Terminal=false
StartupNotify=false
Type=Application
' > redshift.desktop

    chmod o+r *.desktop
    mkdir -p scripts/
    cp /root/scripts/* ./scripts/
    chmod -R o+rx ./scripts/
popd


chmod a-w /home/dan/.config/sakura/sakura.conf
chmod 0600 /home/dan/.ssh/id_rsa
chmod o+r /etc/environment
chmod -R o-rwx /root/
chmod -R o+rX /etc/X11/
echo '127.0.0.1 virtual' >> /etc/hosts
echo '140.82.121.3 github.com' >> /etc/hosts

echo 'session         required       pam_limits.so' >> /etc/pam.d/other
chmod g+rX /home/code
mkdir -p /home/code/src/
chown code:code /home/code/src/
chmod g+rwXs /home/code/src/
ln -s /home/code/src/solcloud/dev-stack/bin/dev-stack-remote.sh /usr/bin/dev
echo 'load-module module-echo-cancel' >> /etc/pulse/default.pa

rm -rf /lib/udev/rules.d/
pushd /etc/udev/rules.d/
rm $(grep -l '# Intentionally empty' * | xargs)
popd

echo "New password for daniel"
passwd daniel
echo "New password for dan"
passwd dan

# Install php
echo "Installing php"
mkdir /tmp/php_install
/etc/internet.sh allow builder
cp build_php.sh /tmp/php_install/
cd /tmp/php_install
chown -R builder:bin /tmp/php_install/
su -c "/bin/bash build_php.sh" builder || exit 1
cd src
cp -a target_root/usr/include/php/ /usr/include/
chown -R 0:0 /usr/include/php/
cp target_root/usr/bin/php /usr/bin/php7
chmod o+x /usr/bin/php7
/etc/internet.sh deny builder
rm -rf /tmp/php_install

cd
chmod o+rx bin/*
cp -a bin/* /usr/bin/
sh reload_iptables.sh

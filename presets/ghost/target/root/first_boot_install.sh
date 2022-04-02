depmod

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
    ln -s /data/desk "/home/$user/Desktop"
    ln -s /data/dwn "/home/$user/Downloads"
    ln -s /tmp "/home/$user/tmp"
    mkdir -p "/home/$user/.config/"
    cp -r /root/.config/dunst/ "/home/$user/.config/"
done
for user in dan; do
    usermod -aG tty,video,audio,input $user # Allow tty and Xorg (gpu,audio,input) login
    mkdir -p /home/$user/.config/
    cp -r /root/.config/{dunst,i3,i3status,mc,xfce4,volumeicon} /home/$user/.config/
    cp /root/.xinitrc /home/$user/
    rm /home/$user/.bash_profile
    echo "alias dmd='dev machine down'" >> /home/$user/.bashrc
    echo 'trap ec ERR' >> /home/$user/.bashrc
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

for user in dan daniel storm editor; do
    usermod -aG code $user
    ln -s /data/desk "/home/$user/Desktop"
done

usermod -u 7001 code
groupmod -g 7001 code

if lsmod | grep 'bochs'; then
    echo 'bindsym Mod1+t exec --no-startup-id $TERMINAL' >> /home/dan/.config/i3/config
    sed 's/set $mod Mod1/set $mod Mod4/' /home/dan/.config/i3/config | sed 's/set $modSecondary Mod4/set $modSecondary Mod5/' > config.temp.in
    mv config.temp.in /home/dan/.config/i3/config
fi

for user in $USERS; do
    chown -R $user:$user "/home/$user"
done

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
Exec=/bin/redshift -x -P && /bin/redshift -l 50.2040:15.8249 -o

Terminal=false
StartupNotify=false
Type=Application
' > redshift.desktop

    chmod o+r *.desktop
    mkdir -p scripts/
    cp /root/scripts/* ./scripts/
    chmod -R o+rx ./scripts/
popd


chmod a-w /home/dan/.config/xfce4/terminal/terminalrc
chmod 0600 /home/dan/.ssh/id_rsa
chmod o+r /etc/environment
chmod -R o-rwx /root/
chmod -R o+rX /etc/X11/
chmod -R o+rX /etc/mc/
chmod -R o+r /etc/pulse/
chmod -R o+r /usr/share/
echo '127.0.0.1 virtual' >> /etc/hosts
echo '140.82.121.3 github.com' >> /etc/hosts

echo 'session         required       pam_limits.so' >> /etc/pam.d/other
chmod g+rX /home/code
mkdir -p /home/code/src/
chown code:code /home/code/src/
chmod g+rwXs /home/code/src/
ln -s /home/code/src/solcloud/dev-stack/bin/dev-stack-remote.sh /usr/bin/dev

rm -rf /lib/udev/rules.d/
rm -f /lib/udev/*.sh
pushd /etc/udev/rules.d/
rm $(grep -l '# Intentionally empty' * | xargs)
popd

echo "New password for daniel"
passwd daniel
echo "New password for dan"
passwd dan

chmod o+rx bin/*
cp -a bin/* /usr/bin/

# Install php
if [ -z "$1" ]; then
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
fi

cd
sh reload_iptables.sh

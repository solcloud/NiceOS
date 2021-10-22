echo "Enter root password"
passwd

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

for user in dan; do
    usermod -aG tty,video,audio,input $user # Allow tty and Xorg (gpu,audio,input) login
    mkdir -p /home/$user/.config/
    cp -r /root/.config/{i3,i3status,mc,alacritty,volumeicon} /home/$user/.config/
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

if lsmod | grep 'bochs-drm'; then
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
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;video/webm;
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


echo '127.0.0.1 virtual' >> /etc/hosts

echo 'session         required       pam_limits.so' >> /etc/pam.d/other
ln -s /home/code/src/solcloud/dev-stack/bin/dev-stack-remote.sh /usr/bin/dev

echo "New password for daniel"
passwd daniel
echo "New password for dan"
passwd dan
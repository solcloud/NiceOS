printf 'firefox' | su -l -c "umask 002 ; XDG_DESKTOP_DIR=/data/desk XDG_DOWNLOAD_DIR=/data/dwn DISPLAY=$DISPLAY ~/firefox/firefox" firefox

# about:config changes
# ui.context_menus.after_mouseup true - Right mouse button instantly clicks the first option in window managers
# extensions.screenshots.disabled true - disable screenshot shit tool at bottom
# media.videocontrols.picture-in-picture.video-toggle.enable false - PiP
# media.videocontrols.picture-in-picture.enabled false - PiP
# media.videocontrols.picture-in-picture.keyboard-controls.enabled false - PiP
# general.smoothScroll false smooth scrolling
# browser.ctrlTab.recentlyUsedOrder false ctrl-tab switching
# media.autoplay.default 5
# permissions.default.geo 2
# permissions.default.desktop-notification 2

# browser.safebrowsing.
# privacy.trackingprotection.
# https://addons.mozilla.org/en-US/firefox/addon/arc-dark-theme-we/

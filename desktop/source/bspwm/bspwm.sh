#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y bspwm sxhkd feh lxappearance playerctl blueman x11-xserver-utils nitrogen scrot xdotool network-manager lm-sensors playerctl i3lock papirus-icon-theme pasystray pavucontrol jgmenu mate-polkit mate-polkit-bin libnotify-bin qt5ct
    sudo pip3 install pywal

    # Dunst
    sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk2.0-dev libxdg-basedir-dev libnotify-dev xdg-utils libwayland-client0
    git clone https://github.com/dunst-project/dunst.git ~/GIT-REPOS/CORE/dunst
    cd ~/GIT-REPOS/CORE/dunst
    sudo it config --global --add safe.directory ~/GIT-REPOS/CORE/dunst
    make -j5 WAYLAND=0
    sudo make WAYLAND=0 install

    # Picom
    sudo apt-get install -y libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson
    # git clone https://github.com/yshui/picom.git ~/GIT-REPOS/CORE/picom
    git clone https://github.com/jonaburg/picom.git ~/GIT-REPOS/CORE/picom
    cd ~/GIT-REPOS/CORE/picom
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install

elif check_cmd dnf; then  # FOR RPM SYSTEMS
    # Install dependencies
    sudo dnf update -y

    # Packages
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

    sudo dnf install -y bspwm sxhkd feh lxappearance playerctl blueman xsetroot dunst nitrogen scrot xdotool network-manager-applet lm_sensors playerctl i3lock papirus-icon-theme pasystray pavucontrol jgmenu lxpolkit libnotify libnotify-devel
    sudo pip3 install pywal

    # Picom
    sudo dnf install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel mesa-libGL-devel meson pcre-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel
    # git clone https://github.com/yshui/picom.git ~/GIT-REPOS/CORE/picom
    git clone https://github.com/jonaburg/picom.git ~/GIT-REPOS/CORE/picom
    cd ~/GIT-REPOS/CORE/picom
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install

elif check_cmd zypper; then  # FOR RPM SYSTEMS

    # Install dependencies
    sudo zypper install -y bspwm sxhkd feh lxappearance playerctl blueman xsetroot dunst nitrogen scrot xdotool NetworkManager-applet pcp-pmda-lmsensors playerctl i3lock papirus-icon-theme pasystray pavucontrol jgmenu mate-polkit libnotify4 libnotify-devel libnotify-tools
    sudo pip3 install pywal

    # Picom
    sudo zypper install -y dbus-1-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb1 libXext-devel libxcb-devel Mesa-libGL-devel meson pcre-devel libpixman-1-0-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorgproto-devel
    # git clone https://github.com/yshui/picom.git ~/GIT-REPOS/CORE/picom
    git clone https://github.com/jonaburg/picom.git ~/GIT-REPOS/CORE/picom
    cd ~/GIT-REPOS/CORE/picom
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
else
    echo "Not able to identify the system"
    exit 0
fi

# Create folders 
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi ~/.local/share/rofi/themes/ ~/.config/alacritty/ ~/.config/dunst/
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/

# xqp
git clone https://github.com/baskerville/xqp.git ~/GIT-REPOS/CORE/xqp
cd ~/GIT-REPOS/CORE/xqp
make
sudo make install

## BSPWM
cd ~/GIT-REPOS/workstation/desktop/source/bspwm
ln -s -f $PWD/config/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/config/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc


# scripts
ln -s -f $PWD/config/scripts ~/.config/bspwm/

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Dunst config
rm -rf ~/.config/dunst
ln -s -f $PWD/config/dunst ~/.config/

# Nitrogen config
rm -rf ~/.config/nitrogen
cp -r $PWD/config/nitrogen ~/.config/

# jgmenu config
rm -rf ~/.config/jgmenu/
ln -s -f $PWD/config/jgmenu ~/.config/

# Copy fonts
# cp -r $PWD/config/fonts/*  ~/.local/share/fonts/

# Themes GTK
## Create files if not exist
mkdir -p ~/.config/gtk-3.0
touch ~/.config/gtk-3.0/settings.ini
mkdir -p ~/.config/gtk-4.0
touch ~/.config/gtk-4.0/settings.ini
## Backup files
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.bkp
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.bkp
## dump config
bash -c 'cat << EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-purple
gtk-font-name=Sans 10
gtk-cursor-theme-name=Breeze_Snow
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=0l
EOF'
bash -c 'cat << EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-purple
gtk-font-name=Sans 10
gtk-cursor-theme-name=Breeze_Snow
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=0
EOF'

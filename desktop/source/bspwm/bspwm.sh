#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y bspwm sxhkd feh lxappearance picom playerctl blueman x11-xserver-utils nitrogen scrot xdotool network-manager lm-sensors playerctl i3lock papirus-icon-theme pasystray pavucontrol
    sudo pip3 install pywal

    # Dunst
    sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk2.0-dev libxdg-basedir-dev libnotify-dev xdg-utils libwayland-client0
    git clone https://github.com/dunst-project/dunst.git ~/GIT-REPOS/CORE/dunst
    cd ~/GIT-REPOS/CORE/dunst
    sudo it config --global --add safe.directory ~/GIT-REPOS/CORE/dunst
    make -j5 WAYLAND=0
    sudo make WAYLAND=0 install


elif check_cmd dnf; then  # FOR RPM SYSTEMS
    # Install dependencies
    sudo dnf update -y

    # Packages
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

    sudo dnf install -y bspwm sxhkd feh lxappearance qt5-qtconfiguration picom playerctl blueman xsetroot dunst nitrogen scrot xdotool network-manager-applet lm_sensors playerctl i3lock papirus-icon-theme pasystray pavucontrol
    sudo pip3 install pywal

else
    echo "Not able to identify the system"
    exit 0
fi

# Create folders 
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi ~/.local/share/rofi/themes/ ~/.config/alacritty/ ~/.config/dunst/
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/

## BSPWM
cd ~/GIT-REPOS/workstation/desktop/source/bspwm
ln -s -f $PWD/config/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/config/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc

# scripts
ln -s -f $PWD/config/scripts ~/.config/bspwm/scripts

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Dunst config
rm -rf ~/.config/dunst/
ln -s -f $PWD/config/dunst ~/.config/dunst

# Nitrogen config
rm -rf ~/.config/nitrogen
cp -r $PWD/config/nitrogen ~/.config/

# Copy fonts
# cp -r $PWD/config/fonts/*  ~/.local/share/fonts/
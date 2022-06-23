#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y bspwm sxhkd feh lxappearance picom playerctl blueman x11-xserver-utils dunst nitrogen scrot xdotool network-manager lm-sensors playerctl i3lock papirus-icon-theme pasystray
    sudo pip3 install pywal


elif check_cmd dnf; then  # FOR RPM SYSTEMS
    # Install dependencies
    sudo dnf update -y

    # Packages
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

    sudo dnf install -y bspwm sxhkd feh lxappearance qt5-qtconfiguration picom playerctl blueman xsetroot dunst nitrogen scrot xdotool network-manager-applet lm_sensors playerctl i3lock papirus-icon-theme pasystray
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
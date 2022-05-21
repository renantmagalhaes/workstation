#!/bin/bash

# Packages
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y i3-gaps feh lxappearance qt5-qtconfiguration picom playerctl blueman xsetroot dunst nitrogen scrot xdotool network-manager-applet lm_sensors
sudo pip3 install pywal

# Create folders
mkdir -p ~/.config/i3 ~/.config/picom/ ~/.local/share/fonts

# I3 config
rm -rf ~/.config/i3
ln -s -f $PWD/config/i3 ~/.config/i3

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Dunst config
rm -rf ~/.config/dunst
ln -s -f $PWD/config/dunst ~/.config/dunst

# Nitrogen config
rm -rf ~/.config/nitrogen
cp -r $PWD/config/nitrogen ~/.config/

# Copy fonts
cp -r $PWD/config/fonts/*  ~/.local/share/fonts/



# # KDE CONFIG
# # KDE i3 session
# cat <<EOF | sudo tee /usr/share/xsessions/plasma-i3.desktop 
# [Desktop Entry]
# Type=XSession
# Exec=env KDEWM=/usr/bin/i3 /usr/bin/startplasma-x11
# DesktopNames=KDE
# Name=Plasma with i3
# Comment=Plasma with i3
# EOF

# # startkderc config for Fedora
# sudo sed -i 's/true/false/g' /etc/xdg/startkderc
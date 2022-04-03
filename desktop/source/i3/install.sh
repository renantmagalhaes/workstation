#!/bin/bash

# Packages
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y i3-gaps feh lxappearance qt5-qtconfiguration picom playerctl blueman xsetroot
sudo pip3 install pywal

# Create folders
mkdir -p ~/.config/i3 ~/.config/picom/ ~/.local/share/fonts

# I3 config
ln -s -f $PWD/config/i3/i3-config ~/.config/i3/config.ini

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

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
#!/bin/bash

# Packages
sudo dnf install -y i3-gaps rofi polybar feh lxappearance qt5-qtconfiguration picom blueman
sudo pip3 install pywal

# Create folders
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi

# I3 config
ln -s -f $PWD/config/i3/i3-config ~/.config/i3/config

# Polybar config
ln -s -f $PWD/config/polybar/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/polybar/poly-launch.sh ~/.config/polybar/poly-launch.sh

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Rofi config
ln -s -f $PWD/config/rofi/config.rasi ~/.config/rofi/config.rasi

## Polybar themes
#https://github.com/adi1090x/polybar-themes

#XCAPE - Bind rofi to SuperKey
sudo dnf install -y git gcc make pkgconfig libX11-devel libXtst-devel libXi-devel
git clone https://github.com/alols/xcape.git ~/GIT-REPOS/CORE/xcape 
cd ~/GIT-REPOS/CORE/xcape
make
sudo make install

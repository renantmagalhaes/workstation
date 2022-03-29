#!/bin/bash

# Packages
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y i3-gaps feh lxappearance qt5-qtconfiguration picom playerctl blueman xsetroot
sudo pip3 install pywal

# Create folders
mkdir -p ~/.config/i3 ~/.config/picom/ ~/.local/share/fonts

# I3 config
ln -s -f $PWD/config/i3/i3-config ~/.config/i3/config

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Copy fonts
cp -r $PWD/config/fonts/*  ~/.local/share/fonts/
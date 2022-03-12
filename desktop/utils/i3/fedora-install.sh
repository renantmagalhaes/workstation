#!/bin/bash

# Packages
sudo dnf install -y i3-gaps rofi polybar
sudo pip3 install pywal

# Create folders
mkdir -p ~/.config/polybar ~/.config/i3

# I3 config
ln -s -f $PWD/config/i3-config ~/.config/i3/config

# Polybar config
ln -s -f $PWD/config/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/poly-launch.sh ~/.config/polybar/poly-launch.sh

## Polybar themes
#https://github.com/adi1090x/polybar-themes
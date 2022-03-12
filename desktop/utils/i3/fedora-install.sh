#!/bin/bash

# Install i3-gaps on fedora

sudo dnf install -y i3-gaps rofi polybar

# Create folders
mkdir -p ~/.config/polybar ~/.config/i3

# I3 config
ln -s -f $PWD/config/i3-config ~/.config/i3/config

# Polybar config
ln -s -f $PWD/config/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/poly-launch.sh ~/.config/polybar/poly-launch.sh
#!/bin/bash

# pkg
sudo dnf install -y polybar

# folder
mkdir -p ~/.config/polybar

# Polybar config
ln -s -f $PWD/config/polybar/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/polybar/launch.sh ~/.config/polybar/launch.sh

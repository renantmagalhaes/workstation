#!/bin/bash

# pkg
sudo dnf install -y polybar mpd wmctrl playerctl material-icons-fonts material-design-light material-design-dark

# MPD config
sudo systemctl enable mpd
sudo systemctl start mpd

# folder
mkdir -p ~/.config/polybar

# Polybar config
ln -s -f $PWD/config/polybar/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/polybar/launch.sh ~/.config/polybar/launch.sh
ln -s -f $PWD/config/polybar/scripts ~/.config/polybar/scripts
ln -s -f $PWD/config/polybar/files ~/.config/polybar/files

#!/bin/bash

# Install dependencies
sudo dnf update
sudo dnf install -y bspwm sxhkd rofi polybar feh lxappearance qt5-qtconfiguration picom blueman playerctl mpd alacritty

# Create folders
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi ~/.local/share/rofi/themes/ ~/.config/alacritty/
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/

# MPD config
sudo systemctl enable mpd
sudo systemctl start mpd

## BSPWM
ln -s -f $PWD/config/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/config/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc

# Polybar config
ln -s -f $PWD/config/polybar/polybar-config ~/.config/polybar/config
ln -s -f $PWD/config/polybar/launch.sh ~/.config/polybar/launch.sh

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Rofi config
git clone https://github.com/lr-tech/rofi-themes-collection.git ~/GIT-REPOS/CORE/rofi-themes-collection
cp -r ~/GIT-REPOS/CORE/rofi-themes-collection/themes/* ~/.local/share/rofi/themes/
ln -s -f $PWD/config/rofi/config.rasi ~/.config/rofi/config.rasi

# Alacritty
ln -s -f $PWD/config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml


#XCAPE - Bind rofi to SuperKey
sudo dnf install -y git gcc make pkgconfig libX11-devel libXtst-devel libXi-devel
git clone https://github.com/alols/xcape.git ~/GIT-REPOS/CORE/xcape 
cd ~/GIT-REPOS/CORE/xcape
make
sudo make install

# # slim and slimlock
# sudo apt install -y slim libpam0g-dev libxrandr-dev libfreetype6-dev libimlib2-dev libxft-dev
# sudo dpkg-reconfigure gdm3 #select slim
# cd  ~/GIT-REPOS/CORE/blue-sky
# sudo cp slim.conf /etc && sudo cp slimlock.conf /etc
# sudo cp default /usr/share/slim/themes
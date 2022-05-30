#!/bin/bash
# Create folder
sudo dnf install -y rofi


# Folders
mkdir -p ~/.local/share/rofi/themes/ 

# Rofi config
git clone https://github.com/lr-tech/rofi-themes-collection.git ~/GIT-REPOS/CORE/rofi-themes-collection
cp -r ~/GIT-REPOS/CORE/rofi-themes-collection/themes/* ~/.local/share/rofi/themes/
# ln -s -f $PWD/config/rofi/rtm-rofi-theme.rasi ~/.config/rofi/rtm-rofi-theme.rasi
# ln -s -f $PWD/config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -s -f $PWD/config/rofi ~/.config/rofi


#XCAPE - Bind rofi to SuperKey
sudo dnf install -y git gcc make pkgconfig libX11-devel libXtst-devel libXi-devel
git clone https://github.com/alols/xcape.git ~/GIT-REPOS/CORE/xcape 
cd ~/GIT-REPOS/CORE/xcape
make
sudo make install

# XCAPE syslink to autostart
ln -s -f $PWD/config/rofi/scripts/xcape.desktop ~/.config/autostart/xcape.desktop

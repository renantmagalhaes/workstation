#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# allow unfree
export NIXPKGS_ALLOW_UNFREE=1

# install packages
nix-env -iA \
nixpkgs.bspwm \
nixpkgs.sxhkd \
nixpkgs.feh \
nixpkgs.lxappearance \
nixpkgs.playerctl \
nixpkgs.blueman \
nixpkgs.nitrogen \
nixpkgs.i3lock \
nixpkgs.papirus-icon-theme \
nixpkgs.pasystray \
nixpkgs.pavucontrol \
nixpkgs.jgmenu \
nixpkgs.mate.mate-polkit \
nixpkgs.libnotify \
nixpkgs.libsForQt5.qt5ct \
nixpkgs.dunst \
nixpkgs.picom-jonaburg


# pywal
sudo pip3 install pywal


# Create folders 
mkdir -p ~/.config/polybar ~/.config/i3 ~/.config/picom ~/.config/rofi ~/.local/share/rofi/themes/ ~/.config/alacritty/ ~/.config/dunst/
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/

# xqp
git clone https://github.com/baskerville/xqp.git ~/GIT-REPOS/CORE/xqp
cd ~/GIT-REPOS/CORE/xqp
make
sudo make install

## BSPWM
cd ~/GIT-REPOS/workstation/desktop/source/bspwm
ln -s -f $PWD/config/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/config/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc


# scripts
ln -s -f $PWD/config/scripts ~/.config/bspwm/

# Picom config
ln -s -f $PWD/config/picom/picom.conf ~/.config/picom/picom.conf

# Dunst config
rm -rf ~/.config/dunst
ln -s -f $PWD/config/dunst ~/.config/

# Nitrogen config
rm -rf ~/.config/nitrogen
cp -r $PWD/config/nitrogen ~/.config/

# jgmenu config
rm -rf ~/.config/jgmenu/
ln -s -f $PWD/config/jgmenu ~/.config/

# Themes GTK
## Create files if not exist
mkdir -p ~/.config/gtk-3.0
touch ~/.config/gtk-3.0/settings.ini
mkdir -p ~/.config/gtk-4.0
touch ~/.config/gtk-4.0/settings.ini
## Backup files
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.bkp
cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.bkp
## dump config
bash -c 'cat << EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Reversal-purple-dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Breeze_Snow
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=0l
EOF'
bash -c 'cat << EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Reversal-purple-dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Breeze_Snow
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=0
EOF'

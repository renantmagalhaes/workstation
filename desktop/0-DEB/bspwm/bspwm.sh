#!/bin/bash

# Install dependencies
sudo apt update &&  sudo apt upgrade -y
sudo apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev rofi 

# Set default folders
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/sxhkd/


# Clone repos
cd ~/GIT-REPOS/CORE
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git

## SXHKD
cd ~/GIT-REPOS/CORE/sxhkd
make
sudo make install

# Install Project
## BSPWM
cd ~/GIT-REPOS/CORE/bspwm
make
sudo make install
ln -s -f ~/GIT-REPOS/workstation/desktop/DEB/bspwm/config/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f ~/GIT-REPOS/workstation/desktop/DEB/bspwm/config/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc


# Set display window
# sudo cp contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

# Install polybar
sudo apt install -y cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev
cd ~/GIT-REPOS/CORE
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install


# Desktop wallpaper
sudo apt install -y feh
 echo 'feh --bg-fill $HOME/Downloads/blue-sky/wallpapers/blue3.png' >> ~/.config/bspwm/bspwmrc

# Polybar
 mkdir ~/.config/polybar
 cd ~/GIT-REPOS/CORE/blue-sky/polybar
 cp * -r ~/.config/polybar
 echo '~/.config/polybar/./launch.sh' >> ~/.config/bspwm/bspwmrc
 cd fonts
 sudo cp * /usr/share/fonts/truetype/

#  # Install Picom
# sudo apt install -y meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev  libpcre2-dev  libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev
# cd ~/GIT-REPOS/CORE
# git clone https://github.com/ibhagwan/picom.git
# cd picom
# git submodule update --init --recursive
# meson --buildtype=release . build
# ninja -C build
 #sudo ninja -C build install

# Theme
# mkdir -p ~/.config/picom
# cp ~/GIT-REPOS/CORE/blue-sky/picom.conf ~/.config/picom/



# VIM
mkdir -p ~/.vim/colors
cd ~/GIT-REPOS/CORE/
cp blue-sky/nord.vim ~/.vim/colors
git clone https://github.com/vim-airline/vim-airline.git
cd vim-airline
cp * -r ~/.vim
cd ~/GIT-REPOS/CORE/
git clone https://github.com/vim-airline/vim-airline-themes.git
cd vim-airline-themes
cp * -r ~/.vim
echo 'colorscheme nord' >> ~/.vimrc
echo 'let g:airline_theme='base16' >> ~/.vimrc'


# Rofi theme
mkdir -p ~/.config/rofi/themes
cp ~/GIT-REPOS/CORE/blue-sky/nord.rasi ~/.config/rofi/themes
rofi-theme-selector #preview the "nord theme" with Enter and apply it with Alt+a

# # slim and slimlock
# sudo apt install -y slim libpam0g-dev libxrandr-dev libfreetype6-dev libimlib2-dev libxft-dev
# sudo dpkg-reconfigure gdm3 #select slim
# cd  ~/GIT-REPOS/CORE/blue-sky
# sudo cp slim.conf /etc && sudo cp slimlock.conf /etc
# sudo cp default /usr/share/slim/themes
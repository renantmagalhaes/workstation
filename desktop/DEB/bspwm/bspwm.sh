#!/bin/bash


# Install dependencies
sudo apt update
sudo apt install -y git gcc make xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev

# Set default folders
mkdir -p ~/GIT-REPOS/CORE
mkdir -p ~/.config/bspwm/bspwmrc
mkdir -p ~/.config/sxhkd


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
sudo cp contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

# Install polybar
sudo apt-get install -y build-essential git xpp libjsoncpp1 libjsoncpp-dev cmake cmake-data pkg-config libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev
cd ~/GIT-REPOS/CORE
git clone https://github.com/jaagr/polybar.git
cd polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install




# Install compton

# Install rofi
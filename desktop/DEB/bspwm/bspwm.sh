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
cp examples/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc
ln -s -f $PWD/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/sxhkd/sxhkdrc


# Set display window
sudo cp contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

# Install polybar

# Install compton

# Install rofi
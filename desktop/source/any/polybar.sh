#!/bin/bash

check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    #pgk
    sudo apt-get install -y mpd wmctrl playerctl fonts-material-design-icons-iconfont fonts-materialdesignicons-webfont yad xsel

    # compile polybar
    # Dependencies
    sudo apt-get install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python3-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-composite0-dev libxcb-composite0-dev libjsoncpp-dev python3-sphinx libuv1-dev
    sudo ln -s /usr/include/jsoncpp/json/ /usr/include/json

    git clone https://github.com/jaagr/polybar.git ~/GIT-REPOS/CORE/polybar
    cd ~/GIT-REPOS/CORE/polybar && ./build.sh


elif check_cmd dnf; then  # FOR RPM SYSTEMS
    # pkg
    sudo dnf install -y polybar mpd wmctrl playerctl material-icons-fonts material-design-light material-design-dark yad xsel

else
    echo "Not able to identify the system"
    exit 0
fi

# MPD config
sudo systemctl enable mpd
sudo systemctl start mpd

# folder
rm -rf ~/.config/polybar

# Polybar config
ln -s -f $PWD/config/polybar ~/.config/polybar

# ln -s -f $PWD/config/polybar/polybar-config ~/.config/polybar/config.ini
# ln -s -f $PWD/config/polybar/launch.sh ~/.config/polybar/launch.sh
# ln -s -f $PWD/config/polybar/scripts ~/.config/polybar/scripts
# ln -s -f $PWD/config/polybar/files ~/.config/polybar/files

#!/bin/bash

# Get current folder
FOLDER_LOCATION=$(pwd)

check_cmd() {
	command -v "$1" 2>/dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
	#pgk
	sudo apt-get install -y mpd wmctrl playerctl fonts-material-design-icons-iconfont fonts-materialdesignicons-webfont yad xsel

	# compile polybar
	# Dependencies
	sudo apt-get install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python3-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-composite0-dev libxcb-composite0-dev libjsoncpp-dev python3-sphinx libuv1-dev unifont
	sudo ln -s /usr/include/jsoncpp/json/ /usr/include/json

	POLYBAR_RELEASE=3.7.2
	wget https://github.com/polybar/polybar/releases/download/$POLYBAR_RELEASE/polybar-$POLYBAR_RELEASE.tar.gz -O ~/GIT-REPOS/CORE/polybar.tar.gz
	cd ~/GIT-REPOS/CORE/ && tar -xvf polybar.tar.gz && cd polybar-$POLYBAR_RELEASE && echo "Y" | ./build.sh

elif check_cmd zypper; then # FOR OpenSuse SYSTEMS
	# pkg
	sudo zypper install -y polybar mpd wmctrl playerctl xsel
	wget https://download-ib01.fedoraproject.org/pub/fedora/linux/releases/36/Everything/x86_64/os/Packages/m/material-design-dark-1.6.2-3.fc36.noarch.rpm -O /tmp/material-design-dark.rpm
	sudo rpm -i /tmp/material-design-dark.rpm
	wget https://download-ib01.fedoraproject.org/pub/fedora/linux/updates/36/Everything/aarch64/Packages/m/material-design-light-1.6.2-6.fc36.noarch.rpm -O /tmp/material-design-light.rpm
	sudo rpm -i /tmp/material-design-light.rpm
	wget https://github.com/google/material-design-icons/raw/master/font/MaterialIcons-Regular.ttf -O ~/.local/share/fonts/MaterialIcons-Regular.ttf
	wget https://github.com/google/material-design-icons/raw/master/font/MaterialIconsOutlined-Regular.otf -O ~/.local/share/fonts/MaterialIconsOutlined-Regular.otf
	wget https://github.com/google/material-design-icons/raw/master/font/MaterialIconsRound-Regular.otf -O ~/.local/share/fonts/MaterialIconsRound-Regular.otf
	wget https://github.com/google/material-design-icons/raw/master/font/MaterialIconsSharp-Regular.otf -O ~/.local/share/fonts/MaterialIconsSharp-Regular.otf
	wget https://github.com/google/material-design-icons/raw/master/font/MaterialIconsTwoTone-Regular.otf -O ~/.local/share/fonts/MaterialIconsTwoTone-Regular.otf
	sudo fc-cache -vf ~/.local/share/fonts/
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
cd $FOLDER_LOCATION
ln -s -f $PWD/dotfiles/polybar ~/.config/polybar

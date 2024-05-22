#!/bin/sh
#
#
#?Site        :https://rtm.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#
# ---------------------------------------------------------------
#
# This script  will make all the changes in the system and will download / install my most used packages.
#
#
#*  -> Preferred applications
#*      - Web: Vivaldi / Chrome
#*      - Editor: Visual Studio Code / Neovim
#*      - Music: Clementine / YT Music(web)
#*      - Video: VLC
#*      - Terminal: Guake
#*      - File Manager: Nautilus
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Flameshot
#
#  --------------------------------------------------------------
#
# RTM

# Verifications

## Root check
if [ “$(id -u)” = “0” ]; then
	echo “Dont run this script as root” 2>&1
	exit 1
fi

# # Check Window System
# if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
# 	echo "Wayland detected. Please change to x11 before running this script"
# 	exit 1
# elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
# 	echo "x11 detect."
# else
# 	echo "Not able to identify the system"
# 	exit 1
# fi

# Check if the user is a member of the sudo or adm group
if groups | grep -E -q "(^| )sudo($| )" || groups | grep -E -q "(^| )adm($| )" || groups | grep -E -q "(^| )root($| )"; then
	echo "User is a member of the sudo, adm or root group."
else
	echo "User is not a member of the sudo or adm group."
	exit 1
fi

# Get current folder
FOLDER_LOCATION=$(pwd)

## Disable cdrom
sudo sed -i 's/deb\ cdrom/\#deb\ cdrom/g' /etc/apt/sources.list

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Dotfiles syslink
ln -s -f $PWD/dotfiles/ ~/.dotfiles

# Install the packages from repo
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wget zsh clementine breeze-cursor-theme dia vim vim-gui-common nmap vlc blender fonts-powerline fonts-cantarell brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome git gnome-icon-theme idle3 fonts-hack-ttf htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome gnome-terminal guake guake-indicator gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload chrome-gnome-shell gnome-menus gir1.2-gmenu-3.0 chrome-gnome-shell gnome-menus pwgen sysstat alacarte ffmpeg neofetch xclip flameshot python3-pip gawk net-tools coreutils gir1.2-gtop-2.0 lm-sensors cheese ncdu whois piper libratbag-tools timeshift adb fastboot materia-gtk-theme gnome-screenshot jp2a unrar-free dnsutils imagemagick alacritty scrot x11-utils wmctrl xdotool software-properties-common apt-transport-https ca-certificates curl flatpak xournal evince jq pulseaudio-utils sassc gcc make nala fd-find python3.11-venv kitty sqlite3 nemo pipx

# Latest Go
bash ./scripts/latest-go.sh

# Latest Node
bash ./scripts/latest-node.sh

## FD path
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd

# Virtualization using KVM + QEMU + libvirt
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-x86 libvirt-clients libvirt-daemon libvirt-daemon-system virtinst virt-manager bridge-utils

# Virtualbox
wget -O- -q https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmour -o /usr/share/keyrings/oracle_vbox_2016.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt-get update
sudo apt-get install -y virtualbox-7.0

# Docker Latest
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl restart docker
sudo usermod -aG docker $USER

## Vivaldi Browser
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
sudo apt-get update
sudo apt-get install -y vivaldi-stable

## Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb
sudo sed -i 's/\,arm64\,armhf//g' /etc/apt/sources.list.d/vscode.list

## Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O /tmp/teamviewer_amd64.deb
sudo dpkg -i /tmp/teamviewer_amd64.deb

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# SCRIPTS

## Brew
bash ./scripts/brew.sh

## Flatpack
bash ./scripts/flatpak.sh
bash ./scripts/gnome-flatpak.sh

## VIM
bash ./scripts/vim.sh

## Fonts
bash ./scripts/fonts.sh

## Themes
bash ./scripts/gnome-themes.sh

## TMUX
bash ./scripts/tmux.sh

## ZSH
bash ./scripts/zsh.sh

## Alacritty
bash ./scripts/alacritty.sh

## Guake
guake --restore-preferences ./utils/guake/rtm-guake-setting

## Neofetch
bash ./scripts/neofetch.sh

## GIT
bash ./utils/git-config/git-config.sh

# LSD
curl https://sh.rustup.rs -sSf | sh -s -- -y
~/.cargo/bin/cargo install lsd

# Colorls
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ruby-dev
sudo gem install colorls

# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

# Install pip packages
pipx install virtualenv
pipx install virtualenvwrapper
pipx install pylint
pipx install bpytop

## Droidcam
bash ./scripts/droidcam.sh

# Install ClamAV
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clamav clamtk
sudo apt-get -f install -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clamav-daemon

#Distrobox
#https://github.com/89luca89/distrobox#installation

# Make sure all package are installed
sudo apt-get -f install -y

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# scrcpy
sudo apt install -y ffmpeg libsdl2-2.0-0 adb wget \
	gcc git pkg-config meson ninja-build libsdl2-dev \
	libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
	libswresample-dev libusb-1.0-0 libusb-1.0-0-dev
git clone https://github.com/Genymobile/scrcpy ~/GIT-REPOS/CORE/scrcpy
cd ~/GIT-REPOS/CORE/scrcpy || return
bash install_release.sh

# Return to original path
cd $FOLDER_LOCATION

# Change to ZSH
zsh
# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
bash

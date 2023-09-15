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
#*      - Web: Edge / Brave
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

# Check if the user is a member of the sudo or adm group
if groups | grep -E -q "(^| )sudo($| )" || groups | grep -E -q "(^| )adm($| )" || groups | grep -E -q "(^| )root($| )"; then
    echo "User is a member of the sudo, adm or root group."
else
    echo "User is not a member of the sudo or adm group."
    exit 1
fi

# Check Window System
if [[ $XDG_SESSION_TYPE == "wayland" ]] ; then
    echo "Wayland detected. Please change to x11 before running this script"
    exit 1
elif [[ $XDG_SESSION_TYPE == "x11" ]] ; then
     echo "x11 detect."
else
    echo "Not able to identify the system"
    exit 1
fi

# Dependencies 

## Disable cdrom
sudo sed -i 's/deb\ cdrom/\#deb\ cdrom/g' /etc/apt/sources.list

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade


# Install the packages from repo
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wget zsh clementine breeze-cursor-theme dia vim vim-gui-common nmap vlc blender fonts-powerline fonts-cantarell brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome git gnome-icon-theme idle3 fonts-hack-ttf htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome gnome-terminal guake guake-indicator gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload chrome-gnome-shell gnome-menus gir1.2-gmenu-3.0 chrome-gnome-shell gnome-menus pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot python3-pip gawk net-tools coreutils gir1.2-gtop-2.0 lm-sensors cheese ncdu whois piper libratbag-tools timeshift adb fastboot materia-gtk-theme gnome-screenshot jp2a unrar-free dnsutils imagemagick alacritty scrot x11-utils wmctrl xdotool software-properties-common apt-transport-https ca-certificates curl flatpak xournal evince jq pulseaudio-utils sassc

# Virtualization using KVM + QEMU + libvirt
sudo apt-get install -y qemu-system-x86 libvirt-clients libvirt-daemon libvirt-daemon-system virtinst virt-manager bridge-utils

# Docker
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo systemctl restart docker

# Add keys, ppa and repos
## Edge Browser
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update
sudo apt install -y microsoft-edge-stable

## Brave Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

## Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
sudo apt-get -f install -y

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb
sudo sed -i 's/\,arm64\,armhf//g' /etc/apt/sources.list.d/vscode.list
sudo apt-get -f install -y

## Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O /tmp/teamviewer_amd64.deb
sudo dpkg -i /tmp/teamviewer_amd64.deb
sudo apt-get -f install -y

# Brew
bash desktop/source/any/brew.sh

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils

# Flatpack
bash desktop/source/any/flatpak.sh
bash desktop/source/gnome/flatpak.sh


# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

# Install pip packages
pip3 install psutil
sudo apt-get -y install bpytop virtualenv virtualenvwrapper pylint

# VIM
bash desktop/source/any/vim.sh

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# Themes
bash desktop/source/gnome/themes.sh

# Install LSD
curl https://sh.rustup.rs -sSf | sh -s -- -y
~/.cargo/bin/cargo install lsd

# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls

#Distrobox
#https://github.com/89luca89/distrobox#installation

## Droidcam
# cd /tmp/
# wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.2.zip
# unzip droidcam_latest.zip -d droidcam
# cd droidcam && sudo ./install-client
# sudo ./install-video

# Install ClamAV
sudo apt install -y clamav clamtk
sudo apt-get -f install -y
sudo apt-get install -y clamav-daemon

#Distrobox
#https://github.com/89luca89/distrobox#installation

# Make sure all package are installed
sudo apt-get -f install -y

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# RTM
# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
bash
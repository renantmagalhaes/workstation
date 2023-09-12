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


#RTM
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

# Update / upgrade
sudo zypper refresh && sudo zypper update

# Install OPI
sudo zypper install -y opi

# Install the packages from suse repo
sudo zypper install -y breeze5-cursors curl guake python3-pip gtk2-engines tree remmina pwgen sysstat alacarte openssl gnome-keyring chrome-gnome-shell libstdc++-devel glibc-static net-tools-deprecated xprop gcc-c++

# Install NIX package manager
sh <(curl -L https://nixos.org/nix/install) --daemon
## Enable find nix apps on system search
rm -rf ~/.local/share/applications
rm -rf ~/.local/share/icons
ln -s ~/.nix-profile/share/applications ~/.local/share/applications
ln -s ~/.nix-profile/share/icons ~/.local/share/icons

# Brew
bash desktop/source/any/brew.sh

# Piper group
sudo usermod -aG games $USER

# Docker
sudo zypper install -y docker docker-compose docker-compose-switch
sudo systemctl enable docker
sudo usermod -G docker -a $USER
sudo systemctl restart docker

# Openssh config
sudo systemctl start sshd
sudo systemctl enable sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

## multimedia codecs
sudo opi codecs

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils
sudo pip3 install wheel
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade

# Flatpack
bash desktop/source/any/flatpak.sh
bash desktop/source/gnome/flatpak.sh


#Install Google Chrome
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub -O /tmp/linux_signing_key.pub
sudo rpm --import /tmp/linux_signing_key.pub
sudo zypper ref
sudo zypper install -y google-chrome-stable

# Install Edge
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper ar https://packages.microsoft.com/yumrepos/edge microsoft-edge
sudo zypper refresh
sudo zypper install -y microsoft-edge-stable

# VIM
bash desktop/source/any/vim.sh

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# Themes
bash desktop/source/gnome/themes.sh

# Install ClamAV
sudo zypper install -y clamav clamtk

#Distrobox
#https://github.com/89luca89/distrobox#installation

# Nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

##Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

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

#RTM
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

# Update / upgrade
sudo zypper refresh && sudo zypper update

# Dotfiles syslink
ln -s -f $PWD/dotfiles/ ~/.dotfiles

# Install OPI
sudo zypper install -y opi

# Install the packages from suse repo
sudo zypper --non-interactive install -y zsh vlc clementine breeze5-cursors vim nmap blender brasero gparted wireshark tmux curl vpnc git htop meld openvpn guake python3-pip gtk2-engines krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar gawk net-tools coreutils ncdu whois piper openssl gnome-keyring chrome-gnome-shell telnet openssh materia-gtk-theme alacritty scrot libstdc++-devel glibc-static net-tools-deprecated xprop wmctrl xdotool gcc-c++ lsd sassc virtualbox golang npm bc fd scrcpy kitty sqlite3 nemo python312-pipx
# virtualbox user
sudo usermod -aG vboxusers $USER
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
yes | sudo opi -y codecs

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils
pipx install wheel
pipx install virtualenv virtualenvwrapper pylint
pipx install bpytop

# Install Vivaldi
sudo rpm --import https://repo.vivaldi.com/stable/linux_signing_key.pub
sudo zypper --no-gpg-checks ar https://repo.vivaldi.com/stable/rpm/x86_64/ Vivaldi
sudo zypper --no-gpg-checks refresh
sudo zypper install -y vivaldi-stable
sudo zypper refresh

# Install Google Chrome
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub -O /tmp/linux_signing_key.pub
sudo rpm --import /tmp/linux_signing_key.pub
sudo zypper ref
sudo zypper install -y google-chrome-stable

## Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

# Create git-folder
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

## Kitty
bash ./scripts/kitty.sh

## Guake
# guake --restore-preferences ./utils/guake/rtm-guake-setting

## Neofetch
bash ./scripts/neofetch.sh

## GIT
bash ./utils/git-config/git-config.sh

# Colorls
sudo zypper install -y ruby ruby-devel ruby nodejs git gcc make libopenssl-devel sqlite3-devel
sudo gem install colorls

# Install ClamAV
sudo zypper install -y clamav clamtk

#Distrobox
#https://github.com/89luca89/distrobox#installation

## Droidcam
bash ./scripts/droidcam.sh

##Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

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

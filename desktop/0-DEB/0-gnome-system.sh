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
#*      - Editor: Visual Studio Code
#*      - Music: Clementine / Spotify(web)
#*      - Video: VLC 
#*      - Terminal: Guake 
#*      - File Manager: Nautilus
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Default Gnome / Flameshot
#//     - Mail: Thunderbird
#
#  --------------------------------------------------------------
#
#  Changelog
#
#    V0.1 2017-12-02 RTM:
#        - Initial release
#
#    V0.2 2017-12-03 RTM:
#        - added more packages from debian repo 
#        - Added tmux plugin manager
#
#    V0.4 2017-12-29
#        - Rework Oh my fish! installation
#        - Auto install bobthefish
#
#    V0.5 2018-05-09
#        - Working on my own VIM config
#        - Removed Sublimetext editor -> Using Visual Code
#        - Change default browser -> Firefox to Google Chrome
#        - Changed default file manager -> Caja to Thunar
#        - Updated GTK theme version
#        - Added Visual Code Studio
#        - Added xfce plugins
#        - Added Draw.IO
#
#    V0.6 2018-05-28
#        - Added Gnome3 plugins
#        - Removed Draw.IO (use web version)
#        - Minor improvements
#
#    V0.7 2018-06-08
#        - Minor improvements
#        - Added VirtualBox
#
#    V0.7 2018-06-16
#        - Minor improvements
#        - Fix virtualbox install
#        - Fix var in oh-my-fish install
#
#    V0.7 2018-07-26
#        - Minor improvements
#        - Remove some gnome3 packages
#        - Add gnome-terminal package
#        - Add Gogh -Color Scheme for Gnome Terminal and Pantheon Terminal (https://github.com/Mayccoll/Gogh)
#        - Changed Thunar > Caja
#        - Changed OMF for Fisherman 
#        - Change default vim install to spacevim
#
#    V0.9 2018-09-08
#        - Add numix-circle icons
#        - Add snap package manager
#        - Add mailspring email client(snap)
#        - Add Slack (snap)
#        - Add Telegram-desktop (snap)
#
#    V0.9.1 2018-09-08
#        - Minor spell check adjustment
#        - Change site to .net domain
#        - Change description
#
#    V1.0 2018-09-29
#        - All major "TODO" fix
#        - Change docky for plank
#        - Add themes for plank
#
#    V1.0.1 2018-10-01
#        - Plank autostart
#
#    V1.0.2 2019-02-28
#        - Vimix Theme
#        - New icons
#        - New fonts
#        - New Cursor
#
#    V1.0.2 2019-08-14
#        - Using Cinnamon now
#        - New theme
#        - New icons
#        - New packages
# 
#        - Install krita(image editing)
#
#    V1.0.5 2019-12-22
#        - Major fixes and rework
#
#    V1.1.0 2019-12-23
#        - Fully automated again
#
#    V1.1.1 2020-05-08
#        - Using Ubuntu 20.04 for now
#        - Minor fixes
#        - Tweaks in themes
#
#    V1.1.2 2020-12-21
#        - Synced with Fedora installation
#        - Using Pop!_OS 20.04 for now
#        - Minor tweaks to make up to date to fedora script
#
#    V1.1.3 2020-12-29
#        - Python path fix
#        - VsCode architecture fix
#
#    V1.1.4 2021-01-02
#        - Vivaldi installation
#        - Guake Settings
#
#    V1.1.5 2021-01-10
#        - Guake Settings updated / Guake autostart
#        - Big ZSH changes (lsd and configs)
#        - New utilities packages installed.
#        - Colorls
#
#    V1.1.6 2021-02-14
#        - Check if is the system is a Pop!_OS installation
#        - GTK WhiteSur script fix
#        - Order of events in script changed to better fit the flow
#
#//    TODO: V1
#//   - Check if is the system is a Pop!_OS installation 
#//   - Install Aws K8S toolkit (cli and auth) - will not do
#//   - System stats inside ZSH (remove Vitals from gnome-extensions)
#//   - Send system stats to tmux panel
#//   - Change Show application icon (GDM WhiteSur theme)
#//   - Test automated deploy

#
#//    TODO: V2
#   - Test exa(https://github.com/ogham/exa) over lsd, when available on stable repo
#//   - Link with Tmux / ZSH / Software / Shell Color folders
# //  - Regex to modify orchis top bar size   

    #// TODO: V3 - Validation
    #// echo $XDG_CURRENT_DESKTOP
    #// echo $XDG_SESSION_TYPE 

# RTM

# Verifications 
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
## add user to sudo group
sudo usermod -a -G sudo rtm

## Disable cdrom
sudo sed -i 's/deb\ cdrom/\#deb\ cdrom/g' /etc/apt/sources.list

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install breeze-cursor-theme fonts-hack-ttf apt-transport-https network-manager-openvpn network-manager-openvpn-gnome gnome-terminal nautilus gnome-tweaks guake guake-indicator gnome-icon-theme chrome-gnome-shell gnome-menus flatpak remmina remmina-plugin-rdp tree pwgen alacarte ca-certificates software-properties-common gir1.2-gtop-2.0 gir1.2-gmenu-3.0 python3-pip x11-utils nala


# Install NIX package manager
sh <(curl -L https://nixos.org/nix/install) --daemon
## Enable find nix apps on system search
rm -rf ~/.local/share/applications
rm -rf ~/.local/share/icons
ln -s ~/.nix-profile/share/applications ~/.local/share/applications
ln -s ~/.nix-profile/share/icons ~/.local/share/icons

# Virtualization using KVM + QEMU + libvirt
 sudo apt-get install -y qemu-system-x86 libvirt-clients libvirt-daemon libvirt-daemon-system virtinst virt-manager bridge-utils

# Docker
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl restart docker
sudo usermod -aG docker $USER


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

# Brew
bash desktop/source/any/brew.sh

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils

# Flatpack
bash desktop/source/any/flatpak.sh
bash desktop/source/gnome/flatpak.sh

## Fix snapd
# sudo ln -s /var/lib/snapd/snap /snap

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip


# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages
pip3 install psutil
sudo apt-get -y install bpytop virtualenv virtualenvwrapper pylint

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# VIM
bash desktop/source/any/vim.sh

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# Themes
bash desktop/source/gnome/themes.sh


#Distrobox
#https://github.com/89luca89/distrobox#installation

# Install ClamAV
sudo apt install -y clamav clamtk
sudo apt-get -f install -y
sudo apt-get install -y clamav-daemon

# Nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

# Make sure all package are installed
sudo apt-get -f install -y

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
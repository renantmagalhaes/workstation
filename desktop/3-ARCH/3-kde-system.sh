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
#*      - Web: Vivaldi / Google Chrome
#*      - Editor: Visual Studio Code
#*      - Music: Clementine
#*      - Video: VLC 
#*      - Terminal: Guake 
#*      - File Manager: Nautilus
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Default Gnome / Flameshot
#//     - Mail: Thunderbird
#
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2021-08-27 RTM:
#       - Started development
#
#// TODO: timeshift


#RTM

#Root check
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
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

#User check
#echo "#########################"
#echo "#			           #"
#echo "#	  User Config      #"
#echo "#			           #"
#echo "#########################"


# Update / upgrade
yes | sudo pacman -Syu

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Install the packages from fedora repo
sudo pacman -Sy zsh vlc clementine vim nmap blender brasero gparted wireshark-qt tmux curl vpnc git htop meld openvpn guake krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar bat gawk net-tools coreutils ncdu whois piper openssl gnome-keyring kvantum-qt5 python-pip flatpak unzip latte-dock libreoffice-fresh kdeplasma-addons

# Bluetooth
yes | sudo pacman -S --needed bluez bluez-utils pulseaudio-bluetooth bluedevil
sudo systemctl enable --now bluetooth
sudo bash -c 'echo "# automatically switch to newly-connected devices " >> /etc/pulse/default.pa'
sudo bash -c 'echo "load-module module-switch-on-connect" >> /etc/pulse/default.pa'

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install snap
git clone https://aur.archlinux.org/snapd.git ~/GIT-REPOS/CORE/snapd
cd ~/GIT-REPOS/CORE/snapd
yes | makepkg -si
sudo systemctl enable --now snapd

## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

#Utils
# # Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages and python path fix
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip


# Flatpack
bash desktop/source/any/flatpak.sh

# Install Teamviewer
yay -Sy teamviewer

# Timeshift 
yay -Sy timeshift

# #Install Google Chrome
yay -Sy google-chrome

# Install Vivaldi
yes | sudo pacman -Syu vivaldi vivaldi-ffmpeg-codecs

# Install Visual Code
yay -Sy visual-studio-code-bin

# nordvpn
yay -Sy nordvpn-bin
sudo systemctl enable --now nordvpnd
sudo gpasswd -a $USER nordvpn

# Fonts
bash desktop/source/any/fonts.sh

# VIM
bash desktop/source/any/vim.sh

# Themes
bash desktop/source/gnome/themes.sh
bash desktop/source/kde/themes.sh

# # Colorls
yes | sudo pacman -Sy ruby
sudo gem install colorls

# # Install LSD
yes | sudo pacman -Sy lsd

# # Install ClamAV
yes | sudo pacman -Sy clamav clamtk

# Virtualbox
sudo pacman -Sy virtualbox virtualbox-guest-iso
sudo usermod -aG vboxusers $USER
sudo modprobe vboxdrv

# Widgets
## Virtual Desktop Bar
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
yes | sh -c "~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-arch.sh"
cd ~/GIT-REPOS/CORE/virtual-desktop-bar/scripts && ./install-applet.sh

## Dash to panel indicator
git clone https://github.com/psifidotos/latte-indicator-dashtopanel.git ~/GIT-REPOS/CORE/latte-indicator-dashtopanel
cd ~/GIT-REPOS/CORE/latte-indicator-dashtopanel && kpackagetool5 -i . -t Latte/Indicator

# # Remove titlebar when maximized window
kwriteconfig5 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
qdbus-qt5 org.kde.KWin /KWin reconfigure

# # Latte dock remap key
kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta  "org.kde.lattedock,/Latte,org.kde.LatteDock,activateLauncherMenu"
qdbus-qt5 org.kde.KWin /KWin reconfigure

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

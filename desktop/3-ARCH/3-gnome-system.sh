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
sudo pacman -Sy zsh vlc clementine vim nmap blender brasero gparted wireshark-qt tmux curl vpnc git htop meld openvpn guake krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar bat gawk net-tools coreutils ncdu whois piper openssl gnome-keyring python-pip flatpak unzip libreoffice-fresh materia-gtk-theme xournalpp android-tools jq neovim
yay -Sy chrome-gnome-shell

# Bluetooth
sudo systemctl enable --now bluetooth

# Brew
bash desktop/source/any/brew.sh

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

# Droidcam
cd /tmp/
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.0.zip
unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client
sudo ./install-video

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

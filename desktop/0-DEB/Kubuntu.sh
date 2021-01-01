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
#    V0.1 2020-12-29 RTM:
#        - Initial release
#
#
#    TODO
# RTM

#Root check
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi


# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install latte-dock zsh clementine breeze-cursor-theme oxygen-cursor-theme oxygen-cursor-theme-extra dia vim vim-gtk vim-gui-common nmap vlc blender gconf-editor fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome snapd gnome-terminal guake guake-indicator gtk2-engines-murrine gtk2-engines-pixbuf gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload arc-theme chrome-gnome-shell virtualbox gnome-shell-extensions gnome-menus gir1.2-gmenu-3.0 gnome-weather flatpak  chrome-gnome-shell gnome-menus gnome-weather pwgen sysstat alacarte alacritty fzf ffmpeg neofetch xclip flameshot unrar 

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flathub Packages 
sudo flatpak install -y flathub com.skype.Client

## Zoom
sudo flatpak install -y flathub us.zoom.Zoom

## Microsoft Teams
sudo flatpak install -y flathub com.microsoft.Fedoraject.Studio

## VLC
sudo flatpak install -y flathub org.videolan.VLC

# Install Handbrake - Video Converter
flatpak install -y flathub fr.handbrake.ghb

#Utils
## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap


# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb

## G910 color profile
sudo apt install -y g810-led
sudo g810-led -p /etc/g810-led/samples/colors
#sudo g810-led -p /etc/g810-led/samples/group_keys
## Set color scheme on bootFedora
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git ~/GIT-REPOS/CORE/awesome-terminal-fonts
sh -c "~/GIT-REPOS/CORE/awesome-terminal-fonts/install.sh"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip -O ~/.local/share/fonts/FiraCode.zip
unzip ~/.local/share/fonts/FiraCode.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/3270.zip -O ~/.local/share/fonts/3270.zip
unzip ~/.local/share/fonts/3270.zip -d ~/.local/share/fonts/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Agave.zip -O ~/.local/share/fonts/Agave.zip
unzip ~/.local/share/fonts/Agave.zip -d ~/.local/share/fonts/

fc-cache -vf ~/.local/share/fonts/

# Kvantum
sudo add-apt-repository ppa:papirus/papirus
sudo apt-get update
sudo apt install qt5-style-kvantum 


# Themes and icons
# Qogir theme
git clone https://github.com/vinceliuice/Qogir-theme.git ~/GIT-REPOS/CORE/Qogir-theme
sh -c "~/GIT-REPOS/CORE/Qogir-theme/install.sh"

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh -a"

# Layan
git clone https://github.com/vinceliuice/Layan-kde.git ~/GIT-REPOS/CORE/Layan-kde
sh -c "~/GIT-REPOS/CORE/Layan-kde/install.sh"


#Widgets 
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
sh -c "~~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-ubuntu.sh"
sh -c "~~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-applet.sh"


# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc

# RTM
# RTM
clear
echo "#################################"
echo "#                         #"
echo "#	    rtm.codes       	#"
echo "# Please reboot your pc   #"
echo "#                         #"
echo "#################################"

clear
echo "*** AFTER INSTALL *** "


echo ""

echo "Set startup applications
* Guake"

echo "*** FONTS *** "
echo "*** Terminal *** "
echo "FiraCode Nerd Font Medium 10"
echo "*** FONTS *** "

echo "*** Guake Terminal Color - Gogh / RTM VERSION *** "

echo ""

echo " ### Install the other tools in this repo! ###"
echo "* ZSH"
echo "* TMUX"
echo "* DEV-TOOLS \n \n"

echo ""

echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

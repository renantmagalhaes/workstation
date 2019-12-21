#!/bin/sh
#
# installer_workstation.sh - Script to install my full DEBIAN 9 workstation experience
#
#Site        :https://renantmagalhaes.net
#Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#                                     <https://github.com/renantmagalhaes>
#
# ---------------------------------------------------------------
#
# This script  will make all the changes in the system and will download / install my most used packages.
#
#
#   => Preferred applications
#       -> Web: Google Chrome
#       -> Mail: Thunderbird
#       -> Editor: Visual Studio Code
#       -> Music: Clementine / Spotify(web)
#       -> Video: VLC 
#       -> Terminal: Guake 
#       -> File Manager: Nautilus
#       -> Record Desktop: OBS Studio
#
#
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2019-09-21 RTM:
#       - Initial release for fedora linux
#


#RTM

#Root check
#if [ “$(id -u)” != “0” ]; then
#echo “This script must be run as root” 2>&1
#exit 1
#fi

#User check
echo "#########################"
echo "#			#"
echo "#	User Config	#"
echo "#			#"
echo "#########################"

echo "Enter your default user name:"
read user

#Update / upgrade
apt-get update && apt-get -y upgrade

#Install rpm fusion
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install the packages from debian repo
sudo dnf install -y rofi obs-studio xorg-x11-drv-nvidia-cuda zsh vlc python-vlc  plank clementine breeze-cursor-theme dia vim nmap gimp blender gconf-editor inkscape brasero gparted wireshark tmux curl net-tools vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python-pip gnome-tweaks

#Install the packages from snap repo

## slack
snap install slack --classic

#Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade


####### Testing google-chrome for now ######
###Install Firefox Latest
#wget -O ~/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64"
#sudo tar xjf ~/FirefoxSetup.tar.bz2 -C /opt/
#sudo mv /usr/lib/firefox/firefox /usr/lib/firefox/firefox_backup
#sudo ln -s /opt/firefox/firefox /usr/lib/firefox/firefox
#rm -rf ~/FirefoxSetup.tar.bz2 

#Create git-folder
mkdir -p ~/GIT-REPOS

#Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome-stable_current_x86_64.rpm
sudo dnf install /tmp/google-chrome-stable_current_amd64.deb

#Install GTK theme Vimix
git clone https://github.com/vinceliuice/vimix-gtk-themes.git ~/GIT-REPOS/vimix
sh -c "~/GIT-REPOS/vimix/Install"

##Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code

#Install Fonts
git clone https://github.com/powerline/fonts.git ~/GIT-REPOS/fonts/
bash ~/GIT-REPOS/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git ~/GIT-REPOS/awesome-terminal-fonts
sh -c "~/GIT-REPOS/awesome-terminal-fonts/install.sh"

fc-cache -vf ~/.local/share/fonts/

##Add Gogh
###Elementary
#runuser -l $user -c 'wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt'
### Grubvbox dark
#runuser -l $user -c 'wget -O xt https://git.io/v7eBS && chmod +x xt && ./xt && rm xt'


#New VIM
curl -sLf https://spacevim.org/install.sh | bash

#Install numix-circle-icons
mkdir -p ~/.icons
git clone https://github.com/numixproject/numix-icon-theme-circle.git ~/.icons
gtk-update-icon-cache ~/.icons/Numix-Circle
gtk-update-icon-cache ~/.icons/Numix-Circle-Light

#Install Vimix Icons
git clone https://github.com/vinceliuice/vimix-icon-theme.git ~/GIT-REPOS/vimix-icons
sh -c "~/GIT-REPOS/vimix-icons/install.sh"

#Install Oranchelo Icons
#mkdir -p /home/rtm/.local/share/icons/
#git clone https://github.com/OrancheloTeam/oranchelo-icon-theme.git /tmp/oranchelo-icons
#sh -c "/tmp/oranchelo-icons/oranchelo-installer.sh"

#Install plank themes
#mkdir -p ~/.local/share/plank/themes
#git clone https://github.com/erikdubois/plankthemes.git ~/.local/share/plank/themes

#Layan theme
git clone https://github.com/vinceliuice/Layan-gtk-theme.git ~/GIT-REPOS/Layan-gtk-theme
sh -c "~/GIT-REPOS/Layan-gtk-theme/install.sh"

#Tela-blue icons
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/Tela-icon-theme
cd ~/GIT-REPOS/Tela-icon-theme/
./install.sh

#Set plank autostart
#curl -o ~/.config/autostart/plank.desktop https://raw.githubusercontent.com/renantmagalhaes/workstation/static-files/plank-fix/plank.desktop


#RTM
clear
echo "#################################"
echo "#                         #"
echo "#	www.renantmagalhaes.net	#"
echo "# Please reboot your pc   #"
echo "#                         #"
echo "#################################"
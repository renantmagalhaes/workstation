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
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2017-12-02 RTM:
#       - Initial release
#
#   V0.2 2017-12-03 RTM:
#       - added more packages from debian repo
#
#   V0.2.1 2017-12-03 RTM:
#       - Syntax adjustments
#       - Add github address in header
#       - Enable blowfish2 vim crypt method
#
#   V0.3 2017-12-11
#       - Added tmux plugin manager
#
#   V0.4 2017-12-29
#       - Rework Oh my fish! installation
#       - Auto install bobthefish
#
#   V0.5 2018-05-09
#       - Working on my own VIM config
#       - Removed Sublimetext editor -> Using Visual Code
#       - Change default browser -> Firefox to Google Chrome
#       - Changed default file manager -> Caja to Thunar
#       - Updated GTK theme version
#       - Added Visual Code Studio
#       - Added xfce plugins
#       - Added Draw.IO
#
#   V0.6 2018-05-28
#       - Added Gnome3 plugins
#       - Removed Draw.IO (use web version)
#       - Minor improvements
#
#   V0.7 2018-06-08
#       - Minor improvements
#       - Added VirtualBox
#
#   V0.7 2018-06-16
#       - Minor improvements
#       - Fix virtualbox install
#       - Fix var in oh-my-fish install
#
#   V0.7 2018-07-26
#       - Minor improvements
#       - Remove some gnome3 packages
#       - Add gnome-terminal package
#       - Add Gogh -Color Scheme for Gnome Terminal and Pantheon Terminal (https://github.com/Mayccoll/Gogh)
#       - Changed Thunar > Caja
#       - Changed OMF for Fisherman
#
#
#   V0.8 2018-08-31
#       - Change default vim install to spacevim
#
#   V0.9 2018-09-08
#       - Add numix-circle icons
#       - Add snap package manager
#       - Add mailspring email client(snap)
#       - Add Slack (snap)
#       - Add Telegram-desktop (snap)
#
#   V0.9.1 2018-09-08
#       - Minor spell check adjustment
#       - Change site to .net domain
#       - Change description
#
#   V1.0 2018-09-29
#       - All major "TODO" fix
#       - Change docky for plank
#       - Add themes for plank
#
#   V1.0.1 2018-10-01
#       - Plank autostart
#
#   V1.0.2 2019-02-28
#       - Vimix Theme
#       - New icons
#       - New fonts
#       - New Cursor
#
#
#   TODO
#   * Install telegram - site
#   * Fonts download
#   * Icons Fix
#   * set ignorecase in ~/.SpaceVim/vimrc
#   * Add zsh / oh-my-zsh as default shell
#   * Auto configure / install plugins for zsh
#   * Search new font for shell

#RTM

#Root check
if [ “$(id -u)” != “0” ]; then
echo “This script must be run as root” 2>&1
exit 1
fi

#User check
echo "#########################"
echo "#			#"
echo "#	User Config	#"
echo "#			#"
echo "#########################"

echo "Enter your default user name:"
read user

# source.list backup
cp /etc/apt/sources.list /etc/apt/sources.list.bkp

#Comment cdrom entry
sed -e '/deb cdrom:/ s/^#*/#/' -i /etc/apt/sources.list

#Add non-free packages
sed -e 's/main/main non-free/g' -i /etc/apt/sources.list


##Virtualbox part1
#Add Key
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
#Register source.list
echo "deb https://download.virtualbox.org/virtualbox/debian stretch contrib" > /etc/apt/sources.list.d/virtualbox.list

#Update / upgrade
apt-get update && apt-get -y upgrade


#Install the packages from debian repo
apt-get -y install zsh plank jq kazam clementine breeze-cursor-theme oxygen-cursor-theme oxygen-cursor-theme-extra dia vim vim-gtk vim-gui-common nmap vlc gimp blender gconf-editor fonts-powerline inkscape brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome snapd gnome-terminal guake guake-indicator gtk2-engines-murrine gtk2-engines-pixbuf python-pip gnome-tweaks

#Install the packages from snap repo

## slack
snap install slack --classic


#Update / upgrade
apt-get update && apt-get -y upgrade

##Virtualbox part2 (need apt-transport-https before install)
apt-get -y install virtualbox-5.2

####### Testing google-chrome for now ######
###Install Firefox Latest
wget -O ~/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64"
sudo tar xjf ~/FirefoxSetup.tar.bz2 -C /opt/
sudo mv /usr/lib/firefox/firefox /usr/lib/firefox/firefox_backup
sudo ln -s /opt/firefox/firefox /usr/lib/firefox/firefox
rm -rf ~/FirefoxSetup.tar.bz2 



#Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
dpkg -i /tmp/google-chrome-stable_current_amd64.deb

#Install GTK theme Vimix- Repo dont exist anymore
git clone https://github.com/vinceliuice/vimix-gtk-themes.git /tmp/vimix
sh -c "/tmp/vimix/Install"

##Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
dpkg -i /tmp/visual_code_amd64.deb

#Install Fonts
git clone https://github.com/powerline/fonts.git /tmp/fonts/
bash /tmp/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git /tmp/awesome-terminal-fonts
sh -c "/tmp/awesome-terminal-fonts/install.sh"

fc-cache -vf ~/.local/share/fonts/

#Add Gogh
##Elementary
runuser -l $user -c 'wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt'
## Grubvbox dark
runuser -l $user -c 'wget -O xt https://git.io/v7eBS && chmod +x xt && ./xt && rm xt'


#New VIM
runuser -l $user -c 'curl -sLf https://spacevim.org/install.sh' | bash

#Install numix-circle-icons
runuser -l $user -c 'mkdir -p ~/.icons'
runuser -l $user -c 'git clone https://github.com/numixproject/numix-icon-theme-circle.git ~/.icons'
runuser -l $user -c 'gtk-update-icon-cache ~/.icons/Numix-Circle'
runuser -l $user -c 'gtk-update-icon-cache ~/.icons/Numix-Circle-Light'

#Install Vimix Icons
git clone https://github.com/vinceliuice/vimix-icon-theme.git /tmp/vimix-icons
sh -c "/tmp/vimix-icons/Installer.sh"

#Install Oranchelo Icons
mkdir -p /home/rtm/.local/share/icons/
git clone https://github.com/OrancheloTeam/oranchelo-icon-theme.git /tmp/oranchelo-icons
sh -c "/tmp/oranchelo-icons/oranchelo-installer.sh"

#Install plank themes
runuser -l $user -c 'mkdir -p ~/.local/share/plank/themes'
runuser -l $user -c 'git clone https://github.com/erikdubois/plankthemes.git ~/.local/share/plank/themes'

#Set plank autostart
runuser -l $user -c 'curl -o ~/.config/autostart/plank.desktop https://raw.githubusercontent.com/renantmagalhaes/workstation/static-files/plank-fix/plank.desktop'


#RTM
clear
echo "#################################"
echo "#                         #"
echo "#	www.renantmagalhaes.net	#"
echo "# Please reboot your pc   #"
echo "#                         #"
echo "#################################"

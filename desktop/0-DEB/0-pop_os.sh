# !/bin/sh
#
#  installer_workstation.sh - Script to install my full workstation experience
#
# Site        :https://renantmagalhaes.net
# Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#                                      <https://github.com/renantmagalhaes>
#
#  ---------------------------------------------------------------
#
#  This script  will make all the changes in the system and will download / install my most used packages.
#
#
#    => Preferred applications
#        -> Web: Google Chrome
#        -> Mail: Thunderbird
#        -> Editor: Visual Studio Code
#        -> Music: Clementine / Spotify(web)
#        -> Video: VLC
#        -> Terminal: Guake
#        -> File Manager: Nautilus
#        -> Record Desktop: OBS Studio
#
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
#
#    V0.2.1 2017-12-03 RTM:
#        - Syntax adjustments
#        - Add github address in header
#        - Enable blowfish2 vim crypt method
#
#    V0.3 2017-12-11
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
#
#
#    V0.8 2018-08-31
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
#    V1.0.3 2019-08-14
#        - Create git folder
#        - Change default path for theme repos

#    V1.0.4 2019-10-01
#        - Install obs studio
#        - Install openshot(video editing)
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
#
#    TODO
#    * https://github.com/vinceliuice/grub2-themes
#    * Install albert
#    *
# RTM

#Root check
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi

# Add keys and ppas
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo add-apt-repository ppa:daniruiz/flat-remix

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install plank zsh clementine breeze-cursor-theme oxygen-cursor-theme oxygen-cursor-theme-extra dia vim vim-gtk vim-gui-common nmap vlc blender gconf-editor fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome snapd gnome-terminal guake guake-indicator gtk2-engines-murrine gtk2-engines-pixbuf gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload arc-theme chrome-gnome-shell virtualbox gnome-shell-extensions gnome-menus gir1.2-gmenu-3.0 gnome-weather flatpak  chrome-gnome-shell gnome-menus gnome-weather pwgen sysstat alacarte alacritty fzf ffmpeg neofetch xclip flameshot unrar 

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flathub Packages
## Slack
sudo flatpak install -y flathub com.slack.Slack

## Skype 
sudo flatpak install -y flathub com.skype.Client

## Zoom
sudo flatpak install -y flathub us.zoom.Zoom

## Microsoft Teams
sudo flatpak install -y flathub com.microsoft.Teams

## Kdenlive
sudo flatpak install -y flathub org.kde.kdenlive

## OBS Studio
sudo flatpak install -y flathub com.obsproject.Studio

## VLC
sudo flatpak install -y flathub org.videolan.VLC

# Install Handbrake - Video Converter
flatpak install -y flathub fr.handbrake.ghb



#Utils
## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

##  telegram
sudo snap install telegram-desktop

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb

## G910 color profile
sudo dnf copr enable -y lkiesow/g810-led # Enable Copr repository
sudo apt install -y g810-led
sudo g810-led -p /etc/g810-led/samples/colors
#sudo g810-led -p /etc/g810-led/samples/group_keys
## Set color scheme on boot
(crontab -l 2>/dev/null; echo "@reboot g810-led -p /etc/g810-led/samples/colors") | crontab -


# Install Fonts
git clone https://github.com/powerline/fonts.git ~/GIT-REPOS/CORE/fonts/
bash ~/GIT-REPOS/CORE/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
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

# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc

# Install numix-circle-icons
mkdir -p ~/.icons
git clone https://github.com/numixproject/numix-icon-theme-circle.git ~/.icons
gtk-update-icon-cache ~/.icons/Numix-Circle
gtk-update-icon-cache ~/.icons/Numix-Circle-Light

# Install GTK theme Vimix
git clone https://github.com/vinceliuice/vimix-gtk-themes.git ~/GIT-REPOS/CORE/vimix-gtk-themes
cd ~/GIT-REPOS/CORE/vimix-gtk-themes
sh -c "./install.sh"
cd

# Install Vimix Icons
git clone https://github.com/vinceliuice/vimix-icon-theme.git ~/GIT-REPOS/CORE/vimix-icons
cd ~/GIT-REPOS/CORE/vimix-icons
sh -c "./install.sh"
cd

# Layan theme
git clone https://github.com/vinceliuice/Layan-gtk-theme.git ~/GIT-REPOS/CORE/Layan-gtk-theme
cd ~/GIT-REPOS/CORE/Layan-gtk-theme
sh -c "./install.sh"
cd

# Tela-icons theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/CORE/Tela-icon-theme
cd ~/GIT-REPOS/CORE/Tela-icon-theme
sh -c "./install.sh -a"
#sh -c "./install.sh"
cd

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
cd ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "./install.sh -a"
#sh -c "./install.sh"
cd

# Nordic theme
git clone https://github.com/EliverLara/Nordic.git ~/GIT-REPOS/CORE/Nordic
sudo mv ~/GIT-REPOS/CORE/Nordic /usr/share/themes/
cd

# Qogir theme
git clone https://github.com/vinceliuice/Qogir-theme.git ~/GIT-REPOS/CORE/Qogir-theme
cd ~/GIT-REPOS/CORE/Qogir-theme
sh -c "./install.sh"
cd

# WhiteSur-gtk-theme
sudo apt install -y gtk2-engines-murrine gtk2-engines-pixbuf sassc optipng inkscape libcanberra-gtk-module libglib2.0-dev libxml2-utils
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ~/GIT-REPOS/CORE/WhiteSur-gtk-theme
cd ~/GIT-REPOS/CORE/WhiteSur-gtk-theme
sh -c "./install.sh"
cd

# Orchis theme
git clone https://github.com/vinceliuice/Orchis-theme.git ~/GIT-REPOS/CORE/Orchis-theme
cd ~/GIT-REPOS/CORE/Orchis-theme
sh -c "./install.sh"
cd

# ChromeOS theme
git clone https://github.com/vinceliuice/ChromeOS-theme.git ~/GIT-REPOS/CORE/ChromeOS-theme
cd ~/GIT-REPOS/CORE/ChromeOS-theme
sh -c "./install.sh"
cd



# Install flat-remix theme
sudo apt install flat-remix-gnome

## VirtualBox
#echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
#sudo apt-get install -y virtualbox-6.1





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
echo "*** Fedora Gnome *** "
echo "# Setup Theme
* Applications: Flat-Remix-Blue-Dark 
* Cursor: Breeze_Snow
* Icons: Tela-circle-blue-dark
* Shell: Flat-Remix-Blue-Darkest-fullPanel / Layan"

echo ""

echo "# Gnome extensions
* Extensions Sync "

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

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
#//     - Mail: Thunderbird
#
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2019-09-21 RTM:
#       - Initial release for fedora linux
#
#   V0.2 2020-10-25 RTM:
#       - Several updates and fix.
#
#   V0.3 2020-11-22 RTM:
#       - Update and fix.
#       - Add Vivaldi to installation
#       - Remove virtualbox (using Gnome Boxes)
#       - Moby-engine
#
#   V0.4 2020-11-22 RTM:
#       - Minor typo fixes
#
#
# TODO:
#   - Check if is the system is a Fedora Workstation installation 
#   - Vivaldi installation
#   - Install Aws K8S toolkit (cli and auth)
#   - ZSH function to not show context-not-set with k8s installed
#   - Test automated deploy
#   - Link with Tmux / ZSH / Software / Shell Color folders
#RTM

#Root check
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi

#User check
#echo "#########################"
#echo "#			#"
#echo "#	User Config	#"
#echo "#			#"
#echo "#########################"

#echo "Enter your default user name:"
#read user

#Update / upgrade
sudo dnf update -y

#Install rpm fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install the packages from debian repo
sudo dnf install -y zsh clementine breeze-cursor-theme vim nmap blender gconf-editor brasero gparted wireshark tmux curl net-tools vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python3-pip gnome-tweaks snapd gtk-murrine-engine gtk2-engines gnome-tweaks krita frei0r-plugins audacity filezilla tree remmina nload arc-theme chrome-gnome-shell gnome-menus gnome-weather pwgen sysstat alacarte gnome-extensions-app alacritty fzf ffmpeg neofetch util-linux-user

# Aditional fedora packages
## Plugins Core
sudo dnf -y install dnf-plugins-core

## multimedia codecs
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils
## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

##Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

## G910 color profile
sudo dnf copr enable -y lkiesow/g810-led # Enable Copr repository
sudo dnf install -y g810-led
sudo g810-led -p /etc/g810-led/samples/colors
#sudo g810-led -p /etc/g810-led/samples/group_keys

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

#Create git-folder
mkdir -p ~/GIT-REPOS

#Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome-stable_current_x86_64.rpm
sudo dnf install -y /tmp/google-chrome-stable_current_x86_64.rpm

#Install Vivaldi
wget https:”
##Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code

#Install Fonts
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

#New VIM
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set paste" >> ~/.vim/vimrc


#Flat-remix Theme
sudo dnf copr enable -y daniruiz/flat-remix
sudo dnf install -y flat-remix-gnome  flat-remix-gtk2-theme flat-remix-gtk3-theme flat-remix-icon-theme

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

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
cd ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "./install.sh -a"
#sh -c "./install.sh"
cd”
# Qogir theme
git clone https://github.com/vinceliuice/Qogir-theme.git ~/GIT-REPOS/CORE/Qogir-theme
cd ~/GIT-REPOS/CORE/Qogir-theme
sh -c "./install.sh"
cd

# WhiteSur-gtk-theme
sudo dnf install -y sassc optipng inkscape glib2-devel
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

# Install Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo dnf -y install teamviewer.x86_64.rpm
rm teamviewer.x86_64.rpm

######################### Using gnome-boxes now #########################
# VirtualBox
#sudo dnf install VirtualBox.x86_64
#sudo dnf -y install wget
#wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
#sudo mv virtualbox.repo /etc/yum.repos.d/virtualbox.repo
#sudo dnf install -y gcc binutils make glibc-devel patch libgomp glibc-headers  kernel-headers kernel-devel-`uname -r` dkms
#sudo dnf install -y VirtualBox-6.1
#sudo usermod -a -G vboxusers ${USER}
#sudo /usr/lib/virtualbox/vboxdrv.sh setup
#cd ~/
#wget https://download.virtualbox.org/virtualbox/6.1.2/Oracle_VM_VirtualBox_Extension_Pack-6.1.2.vbox-extpack

## If kernel update problem
## https://www.virtualbox.org/wiki/Testbuilds > Linux 64-bit > Run .run file
######################### Using gnome-boxes now #########################


#RTM
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
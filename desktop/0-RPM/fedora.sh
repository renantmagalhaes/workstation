#!/bin/sh
#
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
#       -> Web: Google Chrome / Vivaldi
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
#   V0.2 2020-10-25 RTM:
#       - Several updates and fix.
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
sudo dnf update -y

#Install rpm fusion
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install the packages from debian repo
sudo dnf install -y obs-studio zsh vlc python-vlc clementine breeze-cursor-theme vim nmap blender gconf-editor brasero gparted wireshark tmux curl net-tools vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python3-pip gnome-tweaks snapd gtk-murrine-engine gtk2-engines gnome-tweaks krita frei0r-plugins audacity filezilla tree remmina ffmpeg nload arc-theme chrome-gnome-shell gnome-menus gnome-weather pwgen sysstat alacarte gnome-extensions-app alacritty fzf

# Aditional fedora packages
## multimedia codecs
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Update / upgrade
sudo dnf update -y

# Snap syslink
ln -s /var/lib/snapd/snap /snap

#Create git-folder
mkdir -p ~/GIT-REPOS

#Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome-stable_current_x86_64.rpm
sudo dnf install -y /tmp/google-chrome-stable_current_x86_64.rpm

#Install Vivaldi
wget https://downloads.vivaldi.com/stable/vivaldi-stable-3.4.2066.106-1.x86_64.rpm -O /tmp/vivaldi-stable-3.4.2066.106-1.x86_64.rpm
sudo dnf install -y vivaldi-stable-3.4.2066.106-1.x86_64.rpm

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

#Flat-remix Theme
sudo dnf copr enable daniruiz/flat-remix
sudo dnf install flat-remix-gnome
sudo dnf install flat-remix-gtk2-theme flat-remix-gtk3-theme
sudo dnf install flat-remix-icon-theme

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

#Utils
##Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

## Slack
sudo flatpak install flathub com.slack.Slack

## Skype 
sudo flatpak install -y flathub com.skype.Client

## Zoom
sudo flatpak install -y flathub us.zoom.Zoom

## Microsoft Teams
sudo flatpak install -y flathub com.microsoft.Teams

## Kdenlive
flatpak install -y flathub org.kde.kdenlive

# VirtualBox
sudo dnf install VirtualBox.x86_64
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

#RTM
clear
echo "#################################"
echo "#                         #"
echo "#	www.renantmagalhaes.net	#"
echo "# Please reboot your pc   #"
echo "#                         #"
echo "#################################"

clear
echo "*** AFTER INSTALL *** \n "

echo ""
echo "*** Fedora Gnome *** "
echo "# Setup Theme  \n \
* Applications: Qogir-light \n \
* Cursor: Breeze_Snow \n \
* Icons: Tela-circle-black \n \
* Shell: Flat-Remix-Blue-Darkest-fullPanel / Layan / Vimix-laptop \n"

echo ""

echo "# Gnome extensions \n \
* Extensions Sync "

echo "or"

echo "# Gnome extensions \n \
* Dash to dock \n \
* Hide activities button \n \
* Openweather \n \
* Pixel Saver \n \
* Sound input & output device chooser \n \
* KStatusNotifierItem/AppIndicator Support \n \
* User themes \n \
* Vitals \n \
* AlternateTab \n \
* Windowoverlay icons \n \
* Workspace indicator \n \
* Workspace scroll \n \
* Transparent Top Panel *Depends on Theme* \n\
* https://github.com/CorvetteCole/transparent-window-moving (128,20,010) \n \
* Arc menu (Raven Layout)"


echo ""
echo "Set startup applications \n \
* Guake"

echo "*** FONTS *** "
echo "*** Terminal *** "
echo "FiraCode Nerd Font Medium 10"
echo "*** FONTS *** "

echo "*** Guake Terminal Color - Gogh / RTM VERSION *** "
echo '
1 - Select default Shell -> /usr/bin/zsh \n 
2 - Run -> bash -c "$(curl -sLo- https://raw.githubusercontent.com/renantmagalhaes/workstation/master/ShellCollor/rtm-color-scheme.sh)" # RTM Color Scheme \n 
3 - Select default Shell -> /usr/bin/tmux \n'
echo "*** FONTS ***" 


echo " ### Install the other tools in this repo! ###"
echo "* ZSH"
echo "* TMUX"
echo "* DEV-TOOLS \n \n"

echo "#################################"
echo "#                               #"
echo "#    www.renantmagalhaes.net    #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

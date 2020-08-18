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
sudo dnf update -y

#Install rpm fusion
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install the packages from debian repo
sudo dnf install -y rofi obs-studio zsh vlc python-vlc clementine breeze-cursor-theme dia vim nmap gimp blender gconf-editor inkscape brasero gparted wireshark tmux curl net-tools vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python-pip gnome-tweaks snapd gtk-murrine-engine gtk2-engines gnome-tweaks krita kdenlive frei0r-plugins audacity filezilla tree remmina ffmpeg nload arc-theme chrome-gnome-shell gnome-menus gnome-weather 

## slack
sudo wget https://downloads.slack-edge.com/linux_releases/slack-4.8.0-0.1.fc21.x86_64.rpm -O /tmp/slack-4.8.0-0.1.fc21.x86_64.rpm
sudo dnf install -y /tmp/slack-4.8.0-0.1.fc21.x86_64.rpm

#Update / upgrade
sudo dnf update -y

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
sudo dnf install -y /tmp/google-chrome-stable_current_x86_64.rpm



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

##Add Gogh
###Elementary
#runuser -l $user -c 'wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt'
### Grubvbox dark
#runuser -l $user -c 'wget -O xt https://git.io/v7eBS && chmod +x xt && ./xt && rm xt'


#New VIM
curl -sLf https://spacevim.org/install.sh | bash

#Flat-remix Theme
sudo dnf copr enable daniruiz/flat-remix
sudo dnf install flat-remix-gnome

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
cd ~/GIT-REPOS/CORE/Qogir-theme
sh -c "./install.sh"
cd

#Utils
#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true


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
* Dash to dock \n \
* Hide activities button \n \
* Openweather \n \
* Pixel Saver \n \
* Sound input & output device chooser \n \
* KStatusNotifierItem/AppIndicator Support \n \
* User themes \n \
* Vitals \n \
* Windowoverlay icons \n \
* Workspace indicator \n \
* Workspace scroll \n \
* Transparent Top Panel \n\
* https://github.com/CorvetteCole/transparent-window-moving (128,20,010) \n \
* Arc menu (Raven Layout)"

echo "*** UBUNTU *** "
echo ""
echo "# Set startup applications \n \
* Guake \n \
* Albert \n \
* Slack \n \
* Telegram \n \
* Skype \n"

echo "*** FONTS *** "
echo "FiraCode Nerd Font"
echo "*** FONTS *** "

echo "*** Guake Terminal Color - Gogh *** "
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

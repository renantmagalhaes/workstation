# !/bin/sh
# 
#  installer_workstation.sh - Script to install my full DEBIAN 9 workstation experience
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
#    V0.1 2019-12-31 RTM:
#        - Initial release (fork from cinnamon release)
#        - KDE variant added
#
#   
# 
#    TODO
#    * https://github.com/vinceliuice/grub2-themes
#    * Install albert
#    * 
# RTM

Root check
if [ “$(id -u)” != “0” ]; then
echo “This script must be run as root 'sudo ./ubuntu_packages.sh'” 2>&1
exit 1
fi

# User check
echo "#####################"
echo "#                   #"
echo "#    User Config    # "
echo "#                   # "
echo "#####################"

echo "\nEnter your default user name and press ENTER: "
read script_user

# Add keys and ppas
sudo add-apt-repository ppa:obsproject/obs-studio
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

# Update / upgrade
sudo apt-get update && apt-get -y upgrade


# Install the packages from repo
sudo apt-get -y install zsh clementine breeze-cursor-theme oxygen-cursor-theme oxygen-cursor-theme-extra dia vim vim-gtk vim-gui-common nmap vlc gimp blender fonts-powerline inkscape brasero gparted wireshark tmux curl net-tools iproute2  vpnc x2goclient git  idle3 numix-gtk-theme numix-icon-theme fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn snapd guake guake-indicator gtk2-engines-murrine gtk2-engines-pixbuf krita kdenlive frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nautilus

##  slack
sudo wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb -O /tmp/slack-desktop-4.0.2-amd64.deb
sudo dpkg -i /tmp/slack-desktop-4.0.2-amd64.deb

##  telegram
sudo snap install telegram-desktop

#######  Testing google-chrome for now ###### 
## Remove firefox
# sudo dpkg -r firefox
# sudo rm /usr/bin/firefox
# sudo rm /usr/share/applications/firefox.desktop
# 
# 
## # Install Firefox Latest
# wget -O ~/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64"
# sudo tar xjf ~/FirefoxSetup.tar.bz2 -C /opt/
# sudo ln -s /opt/firefox/firefox /usr/bin/firefox
# sudo wget https://raw.githubusercontent.com/renantmagalhaes/workstation/static-files/firefox/firefox.desktop -O /usr/share/applications/firefox.desktop
# rm -rf ~/FirefoxSetup.tar.bz2 

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb


## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb

# Install Fonts
git clone https://github.com/powerline/fonts.git ~/GIT-REPOS/CORE/fonts/
bash ~/GIT-REPOS/CORE/fonts/install.sh

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf

git clone https://github.com/gabrielelana/awesome-terminal-fonts.git ~/GIT-REPOS/CORE/awesome-terminal-fonts
sh -c "~/GIT-REPOS/CORE/awesome-terminal-fonts/install.sh"

fc-cache -vf ~/.local/share/fonts/

# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> cat ~/.vim/vimrc

# Install numix-circle-icons
mkdir -p ~/.icons
git clone https://github.com/numixproject/numix-icon-theme-circle.git ~/.icons
gtk-update-icon-cache ~/.icons/Numix-Circle
gtk-update-icon-cache ~/.icons/Numix-Circle-Light


# Install obs-studio
sudo apt-get install -y obs-studio

# VirtualBox
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt-get install -y virtualbox-6.1

#Permission
chown -R $script_user:$script_user ~/GIT-REPOS

# RTM
clear
echo "*** AFTER INSTALL *** \n "


echo "# Setup panel layout and behavior \n \
* Preferred applications \n \
* Cycle window \n \
* Transparent panel \n \n "

echo "# Setup Theme  \n \
* Windows borders: vimix \n \
* Icons: Tela-dark \n \
* Controls: Layan-dark \n \
* Mouse Pointer: Breeze_Snow \n \
* Desktop: vimix \n \
* Menu Icon: Atom or start-here-symbolic \n \n"

echo "# Set startup applications \n \
* Guake \n \
* Albert \n \
* Slack \n \
* Telegram \n \
* Skype \n \
* Skype \n \n"

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

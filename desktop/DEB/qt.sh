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
#        -> File Manager: Dolphin
#        -> Record Desktop: OBS Studio
#
#
#  --------------------------------------------------------------
#
#  Changelog
#
#    V0.1 2020-03-02 RTM:
#        - Fork from GTK
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

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade


# Install the packages from repo
sudo apt-get -y install latte-dock zsh clementine dia vim nmap vlc blender fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 x2goclient git idle3 fonts-hack-ttf apt-transport-https htop meld openvpn network-manager-openvpn snapd guake guake-indicator krita kdenlive frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg virtualbox

##  slack
sudo wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.2-amd64.deb -O /tmp/slack-desktop-4.4.2-amd64.deb
sudo dpkg -i /tmp/slack-desktop-4.4.2-amd64.deb

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
echo "set ignorecase" >> ~/.vim/vimrc


# Install Vimix Icons
git clone https://github.com/vinceliuice/vimix-icon-theme.git ~/GIT-REPOS/CORE/vimix-icons
cd ~/GIT-REPOS/CORE/vimix-icons
sh -c "./install.sh"
cd

# Layan theme
git clone https://github.com/vinceliuice/Layan-kde.git ~/GIT-REPOS/CORE/Layan-kde-theme
cd ~/GIT-REPOS/CORE/Layan-kde-theme
sh -c "./install.sh"

# Tela-icons theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/CORE/Tela-icon-theme
cd ~/GIT-REPOS/CORE/Tela-icon-theme
sh -c "./install.sh -a"
cd

# Tela-icons theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/CORE/Tela-icon-theme
cd ~/GIT-REPOS/CORE/Tela-icon-theme
sh -c "./install.sh -a"
#sh -c "./install.sh"
cd


# Install obs-studio
sudo apt-get install -y obs-studio

#Permission
chown -R $script_user:$script_user ~/GIT-REPOS
chown -R $script_user:$script_user chown -R rtm:rtm ~/.SpaceVim*
chown -R $script_user:$script_user chown -R rtm:rtm ~/.cache/vimfiles*

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

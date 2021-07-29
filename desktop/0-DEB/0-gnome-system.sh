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
#    V0.1 2017-12-02 RTM:
#        - Initial release
#
#    V0.2 2017-12-03 RTM:
#        - added more packages from debian repo 
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
#    V1.1.2 2020-12-21
#        - Synced with Fedora installation
#        - Using Pop!_OS 20.04 for now
#        - Minor tweaks to make up to date to fedora script
#
#    V1.1.3 2020-12-29
#        - Python path fix
#        - VsCode architecture fix
#
#    V1.1.4 2021-01-02
#        - Vivaldi installation
#        - Guake Settings
#
#    V1.1.5 2021-01-10
#        - Guake Settings updated / Guake autostart
#        - Big ZSH changes (lsd and configs)
#        - New utilities packages installed.
#        - Colorls
#
#    V1.1.6 2021-02-14
#        - Check if is the system is a Pop!_OS installation
#        - GTK WhiteSur script fix
#        - Order of events in script changed to better fit the flow
#
#    TODO: V1
#//   - Check if is the system is a Pop!_OS installation 
#//   - Install Aws K8S toolkit (cli and auth) - will not do
#//   - System stats inside ZSH (remove Vitals from gnome-extensions)
#//   - Send system stats to tmux panel
#//   - Change Show application icon (GDM WhiteSur theme)
#//   - Test automated deploy

#
#    TODO: V2
#   - Test exa(https://github.com/ogham/exa) over lsd, when available on stable repo
#//   - Link with Tmux / ZSH / Software / Shell Color folders
# //  - Regex to modify orchis top bar size   

    # TODO: V3 - Validation
    # echo $XDG_CURRENT_DESKTOP
    # echo $XDG_SESSION_TYPE 

# RTM

# Verifications 
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

# ## Is Pop!_OS ?
# grep -o "ID=pop" /etc/os-release
# RESULT=$?
# if [ $RESULT -eq 0 ]; then
#   echo "Pop!_OS detected"
# else
#   read -rsn1 -p "You are NOT running Pop!_OS. Are you sure to continue? (Press ANY key to confirm)"
# fi

# Add keys, ppa and repos
## VirtualBox
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
## Flat-Remix Theme
#sudo add-apt-repository ppa:daniruiz/flat-remix
## Vivaldi Browser
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install plank zsh clementine breeze-cursor-theme dia vim vim-gtk vim-gui-common nmap vlc blender gconf-editor fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome git gnome-icon-theme idle3 fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome snapd gnome-terminal guake guake-indicator gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload chrome-gnome-shell virtualbox gnome-shell-extensions gnome-menus gir1.2-gmenu-3.0 flatpak chrome-gnome-shell gnome-menus pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar python3-pip bat gawk net-tools coreutils gir1.2-gtop-2.0 lm-sensors obs-studio cheese ncdu whois pdfshuffler piper libratbag-tools
sudo apt-get -f install -y


# vboxuser
sudo usermod -aG vboxusers $USER

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils

## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

## Skype
sudo flatpak install -y flathub com.skype.Client

## Zoom
sudo flatpak install -y flathub us.zoom.Zoom

## Install Handbrake - Video Converter
sudo flatpak install -y flathub fr.handbrake.ghbE

## Microsoft teams
sudo flatpak install -y flathub com.microsoft.Teams

## FFaudioConverter
sudo flatpak install -y flathub com.github.Bleuzen.FFaudioConverter

## Kdenlive
sudo flatpak install flathub -y org.kde.kdenlive

## MkCron
sudo snap install mkcron

## Slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb -O /tmp/slack-desktop.deb
sudo dpkg -i /tmp/slack-desktop.deb

## LSD
wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb -O /tmp/lsd_amd64.deb
sudo dpkg -i /tmp/lsd_amd64.deb

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

## Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O /tmp/teamviewer_amd64.deb
sudo dpkg -i /tmp/teamviewer_amd64.deb
sudo apt-get -f install -y

## Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
sudo apt-get -f install -y

## Install Vivaldi Browser
sudo apt install -y vivaldi-stable

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb
sudo sed -i 's/\,arm64\,armhf//g' /etc/apt/sources.list.d/vscode.list
sudo apt-get -f install -y


## Guake Configs
mkdir -p ~/.config/autostart/
#guake --save-preferences ../../guake/rtm-guake-settings
guake --restore-preferences ../../guake/rtm-guake-settings 
cat <<EOF >> ~/.config/autostart/guake.desktop
[Desktop Entry]
Name=Guake Terminal
Comment=Use the command line in a Quake-like terminal
TryExec=guake
Exec=guake
Icon=guake
Type=Application
Categories=GNOME;GTK;System;Utility;TerminalEmulator;
StartupNotify=true
X-Desktop-File-Install-Version=0.22
EOF

# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade
sudo apt-get -f install -y

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set cryptmethod=blowfish2" >> ~/.vim/vimrc
echo "set viminfo=" >> ~/.vim/vimrc
sudo apt-get -f install -y

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

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

## cascadia font for vscode
wget https://github.com/microsoft/cascadia-code/releases/download/v2105.24/CascadiaCode-2105.24.zip -O /tmp/CascadiaCode-2105.24.zip
unzip /tmp/CascadiaCode-2105.24.zip -d /tmp/
cp /tmp/ttf/CascadiaCodePL.ttf  ~/.local/share/fonts/
cp /tmp/ttf/CascadiaCode.ttf  ~/.local/share/fonts/

fc-cache -vf ~/.local/share/fonts/

# Nordic theme
git clone https://github.com/EliverLara/Nordic.git ~/GIT-REPOS/CORE/Nordic
sudo mv ~/GIT-REPOS/CORE/Nordic /usr/share/themes/

# Qogir theme
git clone https://github.com/vinceliuice/Qogir-theme.git ~/GIT-REPOS/CORE/Qogir-theme
sh -c "~/GIT-REPOS/CORE/Qogir-theme/install.sh"

# Orchis theme
git clone https://github.com/vinceliuice/Orchis-theme.git ~/GIT-REPOS/CORE/Orchis-theme
sh -c "~/GIT-REPOS/CORE/Orchis-theme/install.sh"

# ChromeOS theme
git clone https://github.com/vinceliuice/ChromeOS-theme.git ~/GIT-REPOS/CORE/ChromeOS-theme
sh -c "~/GIT-REPOS/CORE/ChromeOS-theme/install.sh"

# WhiteSur-gtk-theme
sudo apt install -y gtk2-engines-murrine gtk2-engines-pixbuf sassc optipng inkscape libcanberra-gtk-module libglib2.0-dev libxml2-utils libnotify-bin libglib2.0-dev-bin
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ~/GIT-REPOS/CORE/WhiteSur-gtk-theme
sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/install.sh -i void -N mojave -c dark -c light -t all 
# sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/tweaks.sh -g 
sudo apt-get -f install -y


# Fluent Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git ~/GIT-REPOS/CORE/Fluent-gtk-theme
sh -c "~/GIT-REPOS/CORE/Fluent-gtk-theme/install.sh"

# Dracula theme
wget https://github.com/dracula/gtk/archive/master.zip -O ~/.themes/Dracula.zip
unzip ~/.themes/Dracula.zip -d ~/.themes/Dracula
mv ~/.themes/Dracula/gtk-master/* ~/.themes/Dracula

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh -a"

# Flatery Icon Theme
git clone https://github.com/cbrnix/Flatery.git ~/GIT-REPOS/CORE/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery ~/.local/share/icons/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery-Indigo-Dark ~/.local/share/icons/Flatery-Indigo-Dark

## Dock icon 
#mv ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid.svg ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid-backup.svg
#cp  ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/src/assets/gnome-shell/activities-black/activities-void.svg ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid.svg

# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls
sudo apt-get -f install -y

# Install flat-remix theme
# sudo apt install -y flat-remix-gnome flat-remix flat-remix-gtk
# sudo apt-get -f install -y


# Install ClamAV
sudo apt install -y clamav clamtk
sudo apt-get -f install -y
sudo apt-get install -y clamav-daemon

# Make sure all package are installed
sudo apt-get -f install -y

# RTM
# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

#clear
echo "*** AFTER INSTALL *** "

echo ""
echo "*** Gnome *** "
echo "# Setup Theme
* Applications: ChromeOS-dark-compact 
* Cursor: Breeze_Snow
* Icons: Flatery-Indigo-Dark
* Shell: Orchis-dark-compact"

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

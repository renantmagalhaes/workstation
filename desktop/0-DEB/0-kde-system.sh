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
#*      - Music: Clementine / YT Music(web)
#*      - Video: VLC 
#*      - Terminal: Guake 
#*      - File Manager: Dolphin
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Flameshot
#//     - Mail: Thunderbird
#
#  --------------------------------------------------------------
#
#  Changelog
#
#    V0.1 2020-12-29 RTM:
#        - Initial release
#
#    V0.1 2021-07-17 RTM:
#        - Update latest packages
#
#
#
#    TODO
# RTM


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

# Add keys, ppa and repos
## VirtualBox
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

## Ubuntu backports for latte-dock
sudo add-apt-repository ppa:kubuntu-ppa/backports
sudo apt update
sudo apt dist-upgrade

## Vivaldi Browser
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'

# ## Kvantum
# sudo add-apt-repository ppa:papirus/papirus

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install zsh clementine breeze-cursor-theme vim vim-gui-common nmap vlc blender fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 x2goclient git idle3 fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn snapd guake guake-indicator krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload virtualbox flatpak pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar python3-pip bat gawk net-tools coreutils gir1.2-gtop-2.0 obs-studio cheese ncdu whois pdfshuffler piper libratbag-tools qt5-style-kvantum qt5-style-kvantum-themes gnome-keyring timeshift adb fastboot materia-gtk-theme xournal
#sudo apt-get -y install latte-dock # installing git version for now.
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
sudo flatpak install -y flathub -y org.kde.kdenlive

## Telegram Desktop
sudo flatpak install -y flathub org.telegram.desktop

## MkCron
# sudo snap install mkcron

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


# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade
sudo apt-get -f install -y

# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set cryptmethod=blowfish2" >> ~/.vim/vimrc
echo "set viminfo=" >> ~/.vim/vimrc
sudo apt-get -f install -y

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# Themes
# Qogir
git clone https://github.com/vinceliuice/Qogir-kde.git ~/GIT-REPOS/CORE/Qogir-kde
sh -c "~/GIT-REPOS/CORE/Qogir-kde/install.sh"

# Layan
git clone https://github.com/vinceliuice/Layan-kde.git ~/GIT-REPOS/CORE/Layan-kde
sh -c "~/GIT-REPOS/CORE/Layan-kde/install.sh"

# Orchis
git clone https://github.com/vinceliuice/Orchis-kde.git ~/GIT-REPOS/CORE/Orchis-kde
sh -c "~/GIT-REPOS/CORE/Orchis-kde/install.sh"

# ChromeOS
git clone https://github.com/vinceliuice/ChromeOS-kde.git ~/GIT-REPOS/CORE/ChromeOS-kde
sh -c "~/GIT-REPOS/CORE/ChromeOS-kde/install.sh"

git clone https://github.com/vinceliuice/ChromeOS-theme.git ~/GIT-REPOS/CORE/ChromeOS-theme
sh -c "~/GIT-REPOS/CORE/ChromeOS-theme/install.sh"

# WhiteSur
git clone https://github.com/vinceliuice/WhiteSur-kde.git ~/GIT-REPOS/CORE/WhiteSur-kde
sh -c "~/GIT-REPOS/CORE/WhiteSur-kde/install.sh"

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh blue"
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh black"

# Tela--icon-theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git ~/GIT-REPOS/CORE/Tela-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-icon-theme/install.sh blue"
sh -c "~/GIT-REPOS/CORE/Tela-icon-theme/install.sh black"

# Reversal
git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git ~/GIT-REPOS/CORE/Reversal-icon-theme
sh -c "~/GIT-REPOS/CORE/Reversal-icon-theme/install.sh -a"

# Flatery Icon Theme
git clone https://github.com/cbrnix/Flatery.git ~/GIT-REPOS/CORE/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery ~/.local/share/icons/Flatery
ln -s ~/GIT-REPOS/CORE/Flatery/Flatery-Indigo-Dark ~/.local/share/icons/Flatery-Indigo-Dark


# Fluent Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git ~/GIT-REPOS/CORE/Fluent-gtk-theme
sh -c "~/GIT-REPOS/CORE/Fluent-gtk-theme/install.sh"

git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/GIT-REPOS/CORE/Fluent-icon-theme
sh -c "~/GIT-REPOS/CORE/Fluent-icon-theme/install.sh"
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist /usr/share/icons/Fluent-cursors
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist-dark /usr/share/icons/Fluent-dark-cursors

# Materia KDE
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/materia-kde/master/install.sh | sh


# Widgets
## Virtual Desktop Bar
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
yes | sh -c "~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-ubuntu.sh"
cd ~/GIT-REPOS/CORE/virtual-desktop-bar/scripts && ./install-applet.sh

## Dash to panel indicator
git clone https://github.com/psifidotos/latte-indicator-dashtopanel.git ~/GIT-REPOS/CORE/latte-indicator-dashtopanel
cd ~/GIT-REPOS/CORE/latte-indicator-dashtopanel && kpackagetool5 -i . -t Latte/Indicator

# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls
sudo apt-get -f install -y

# Droidcam
cd /tmp/
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.0.zip
unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client
sudo ./install-videos

# Install ClamAV
sudo apt install -y clamav clamtk
sudo apt-get -f install -y
sudo apt-get install -y clamav-daemon

# Make sure all package are installed
sudo apt-get -f install -y

# # Remove titlebar when maximized window
#kwriteconfig5 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
#qdbus org.kde.KWin /KWin reconfigure

# # Latte dock remap key
#kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta  "org.kde.lattedock,/Latte,org.kde.LatteDock,activateLauncherMenu"
#qdbus org.kde.KWin /KWin reconfigure
#Revert to kde dock
#kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu"
#qdbus org.kde.KWin /KWin reconfigure

# Plasma sync configs
# TODO: find a way to install all packages via cli.
# https://store.kde.org/p/1298955/

# Latte-dock
git clone https://invent.kde.org/plasma/latte-dock.git ~/GIT-REPOS/CORE/latte-dock
sudo apt-get install -y cmake extra-cmake-modules qtdeclarative5-dev libqt5x11extras5-dev libkf5iconthemes-dev libkf5plasma-dev libkf5windowsystem-dev libkf5declarative-dev libkf5xmlgui-dev libkf5activities-dev build-essential libxcb-util-dev libkf5wayland-dev git gettext libkf5archive-dev libkf5notifications-dev libxcb-util0-dev libsm-dev libkf5crash-dev libkf5newstuff-dev libxcb-shape0-dev libxcb-randr0-dev libx11-dev libx11-xcb-dev kirigami2-dev
cd ~/GIT-REPOS/CORE/latte-dock && sh install.sh

# Widgets
## Virtual Desktop Bar
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
sh -c "~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-ubuntu.sh"
cd ~/GIT-REPOS/CORE/virtual-desktop-bar/scripts && ./install-applet.sh

## applet-window-buttons
git clone https://github.com/psifidotos/applet-window-buttons.git ~/GIT-REPOS/CORE/applet-window-buttons
sudo apt install -y g++ extra-cmake-modules qtbase5-dev qtdeclarative5-dev libkf5declarative-dev libkf5plasma-dev libkdecorations2-dev gettext
cd ~/GIT-REPOS/CORE/applet-window-buttons && sh install.sh

## applet-window-title
git clone https://github.com/psifidotos/applet-window-title.git ~/GIT-REPOS/CORE/applet-window-title
cd ~/GIT-REPOS/CORE/applet-window-title && plasmapkg2 -i .

## applet-window-appmenu
git clone https://github.com/psifidotos/applet-window-appmenu.git ~/GIT-REPOS/CORE/applet-window-appmenu
sudo apt-get install -y make cmake extra-cmake-modules qtdeclarative5-dev libkf5plasma-dev libqt5x11extras5-dev g++ libsm-dev libkf5configwidgets-dev libkdecorations2-dev libxcb-randr0-dev libkf5wayland-dev plasma-workspace-dev
cd ~/GIT-REPOS/CORE/applet-window-appmenu && sh install.sh

# RTM
# RTM

echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
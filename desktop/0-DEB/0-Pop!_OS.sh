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
#    TODO V2
#//   - Check if is the system is a Pop!_OS installation 
#//   - Install Aws K8S toolkit (cli and auth) - will not do
#//   - System stats inside ZSH (remove Vitals from gnome-extensions)
#//   - Send system stats to tmux panel
#   - Change Show application icon (GDM WhiteSur theme)
#   - Test automated deploy

#
#    TODO V3
#   - Test exa(https://github.com/ogham/exa) over lsd, when available on stable repo
#   - Link with Tmux / ZSH / Software / Shell Color folders

# RTM

# Verifications 
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi

## Is Pop!_OS ?
grep -o "ID=pop" /etc/os-release
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Pop!_OS detected"
else
  read -rsn1 -p "You are NOT running Pop!_OS. Are you sure to continue? (Press ANY key to confirm)"
fi

# Add keys and ppas
## VirtualBox
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
## Flat-Remix Theme
sudo add-apt-repository ppa:daniruiz/flat-remix
## Vivaldi Browser
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'

# Update / upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install plank zsh clementine breeze-cursor-theme oxygen-cursor-theme oxygen-cursor-theme-extra dia vim vim-gtk vim-gui-common nmap vlc blender gconf-editor fonts-powerline brasero gparted wireshark tmux curl net-tools iproute2 vpnc-scripts network-manager-vpnc vpnc network-manager-vpnc-gnome x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme fonts-hack-ttf apt-transport-https htop meld dconf-cli openvpn network-manager-openvpn network-manager-openvpn-gnome snapd gnome-terminal guake guake-indicator gnome-tweaks nautilus nautilus-admin nautilus-data nautilus-extension-gnome-terminal nautilus-share krita frei0r-plugins audacity filezilla tree remmina remmina-plugin-rdp ffmpeg nload arc-theme chrome-gnome-shell virtualbox gnome-shell-extensions gnome-menus gir1.2-gmenu-3.0 gnome-weather flatpak chrome-gnome-shell gnome-menus gnome-weather pwgen sysstat alacarte alacritty fzf ffmpeg neofetch xclip flameshot unrar python3-pip bat gawk net-tools coreutils gir1.2-gtop-2.0 lm-sensors obs-studio kdenlive

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils

## Skype
sudo flatpak install -y flathub com.skype.Client

## Zoom
sudo flatpak install -y flathub us.zoom.Zoom

# Install Handbrake - Video Converter
sudo flatpak install -y flathub fr.handbrake.ghbE

# Microsoft teams
sudo flatpak install -y flathub com.microsoft.Teams

# Slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb -O /tmp/slack-desktop.deb
sudo dpkg -i /tmp/slack-desktop.deb

## LSD
wget https://github.com/Peltoche/lsd/releases/download/0.19.0/lsd_0.19.0_amd64.deb -O /tmp/lsd_amd64.deb
sudo dpkg -i /tmp/lsd_amd64.deb

## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

## Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O /tmp/teamviewer_amd64.deb
sudo dpkg -i /tmp/teamviewer_amd64.deb

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

# Install Vivaldi Browser
sudo apt install -y vivaldi-stable

## Install Visual Code
wget --content-disposition https://go.microsoft.com/fwlink/?LinkID=760868 -O /tmp/visual_code_amd64.deb
sudo dpkg -i /tmp/visual_code_amd64.deb
sudo sed -i 's/\,arm64\,armhf//g' /etc/apt/sources.list.d/vscode.list

## Guake Configs
mkdir -p ~/.config/autostart/
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

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper
sudo pip3 install bpytop --upgrade

#Isolate Alt-Tab workspaces
gsettings set org.gnome.shell.app-switcher current-workspace-only true

## G810 color profile
sudo apt install -y g810-led
sudo g810-led -p /etc/g810-led/samples/colors
#sudo g810-led -p /etc/g810-led/samples/group_keys
## Set color scheme on boot
(crontab -l 2>/dev/null; echo "@reboot g810-led -p /usr/share/doc/g810-led/examples/sample_profiles/colors") | crontab -

# New VIM
sudo apt-get install -y build-essential
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc

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

fc-cache -vf ~/.local/share/fonts/

# Layan theme
git clone https://github.com/vinceliuice/Layan-gtk-theme.git ~/GIT-REPOS/CORE/Layan-gtk-theme
sh -c "~/GIT-REPOS/CORE/Layan-gtk-theme/install.sh"

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh -a"

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
sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/install.sh -g
~/GIT-REPOS/CORE/WhiteSur-gtk-theme/src/other/dash-to-dock/install.sh -d

# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls

# Install flat-remix theme
sudo apt install -y flat-remix-gnome flat-remix flat-remix-gtk 

# Make sure all package are installed
sudo apt-get -f install -y

# RTM
# RTM
#clear
echo "#################################"
echo "#                         #"
echo "#	    rtm.codes       	#"
echo "# Please reboot your pc   #"
echo "#                         #"
echo "#################################"

#clear
echo "*** AFTER INSTALL *** "

echo ""
echo "*** Gnome *** "
echo "# Setup Theme
* Applications: ChromeOS-dark-compact 
* Cursor: Breeze_Snow
* Icons: Tela-circle-blue-dark
* Shell: WhiteSur-dark"

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

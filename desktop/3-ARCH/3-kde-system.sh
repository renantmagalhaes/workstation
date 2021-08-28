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
#*      - Music: Clementine
#*      - Video: VLC 
#*      - Terminal: Guake 
#*      - File Manager: Nautilus
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Default Gnome / Flameshot
#//     - Mail: Thunderbird
#
# --------------------------------------------------------------
#
# Changelog
#
#   V0.1 2021-08-27 RTM:
#       - Started development
#
# TODO: timeshift


#RTM

#Root check
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

#User check
#echo "#########################"
#echo "#			           #"
#echo "#	  User Config      #"
#echo "#			           #"
#echo "#########################"


# Update / upgrade
yes | sudo pacman -Syu

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Install the packages from fedora repo
yes | sudo pacman -Sy zsh vlc clementine vim nmap blender brasero gparted wireshark-qt tmux curl vpnc git htop meld openvpn guake krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar bat gawk net-tools coreutils ncdu whois piper openssl gnome-keyring kvantum-qt5 python-pip flatpak unzip latte-dock libreoffice-fresh 

# Bluetooth
yes | sudo pacman -S --needed bluez bluez-utils pulseaudio-bluetooth bluedevil
sudo systemctl enable --now bluetooth
sudo bash -c 'echo "# automatically switch to newly-connected devices " >> /etc/pulse/default.pa'
sudo bash -c 'echo "load-module module-switch-on-connect" >> /etc/pulse/default.pa'
# It happens after updates or if you use dual-booting with Windows that the headset only connects HSB/HFP.
#
# Sometimes it helps to simple disable and re-enable device.
#
# If that does not help try to remove the disable device and reinitialize it.
#
# And last if all of that do not work try rfkill:
#
# sudo rfkill block bluetooth
# sudo rfkill unblock bluetooth
# sudo systemctl restart bluetooth


# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install snap
git clone https://aur.archlinux.org/snapd.git ~/GIT-REPOS/CORE/snapd
cd ~/GIT-REPOS/CORE/snapd
yes | makepkg -si
sudo systemctl enable --now snapd

## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

#Utils
# # Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages and python path fix
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

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

## FFaudioConverter
sudo flatpak install -y flathub com.github.Bleuzen.FFaudioConverter

# ## MkCron
# sudo snap install mkcron

# Install Teamviewer
yay -Sy teamviewer

# Timeshift 
yay -Sy timeshift

# #Install Google Chrome
yay -Sy google-chrome

# Install Vivaldi
yes | sudo pacman -Syu vivaldi vivaldi-ffmpeg-codecs

# Install Visual Code
yay -Sy visual-studio-code-bin

# nordvpn
yay -Sy nordvpn-bin
sudo systemctl enable --now nordvpnd
sudo gpasswd -a $USER nordvpn

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

# New VIM
curl -sLf https://spacevim.org/install.sh | bash
echo "set ignorecase" >> ~/.vim/vimrc
echo "set paste" >> ~/.vim/vimrc

# Themes
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
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh -a"

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

# # Colorls
yes | sudo pacman -Sy ruby
sudo gem install colorls

# # Install LSD
yes | sudo pacman -Sy lsd

# # Install ClamAV
yes | sudo pacman -Sy clamav clamtk

# Virtualbox
sudo pacman -Sy virtualbox virtualbox-guest-iso
sudo usermod -aG vboxusers $USER
sudo modprobe vboxdrv

# Widgets
## Virtual Desktop Bar
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
yes | sh -c "~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-arch.sh"
cd ~/GIT-REPOS/CORE/virtual-desktop-bar/scripts && ./install-applet.sh

## Dash to panel indicator
git clone https://github.com/psifidotos/latte-indicator-dashtopanel.git ~/GIT-REPOS/CORE/latte-indicator-dashtopanel
cd ~/GIT-REPOS/CORE/latte-indicator-dashtopanel && kpackagetool5 -i . -t Latte/Indicator

# # Remove titlebar when maximized window
kwriteconfig5 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
qdbus-qt5 org.kde.KWin /KWin reconfigure

# # Latte dock remap key
kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta  "org.kde.lattedock,/Latte,org.kde.LatteDock,activateLauncherMenu"
qdbus-qt5 org.kde.KWin /KWin reconfigure

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

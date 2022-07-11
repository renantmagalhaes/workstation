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
#   V0.1 2019-09-21 RTM:
#       - Initial release for fedora linux
#
#   V0.2 2020-10-25 RTM:
#       - Packages added
#
#   V0.3 2020-11-22 RTM:
#       - Packages added
#       - Add Vivaldi to installation
#       - Remove virtualbox (using Gnome Boxes)
#       - Moby-engine
#
#   V0.4 2020-11-22 RTM:
#       - Minor typo fixes
#
#   V0.5 2020-11-27 RTM:
#       - Remember grub2 last choice
#       - Increse DNF speed
#       - g810-led cron setup
#       - rpm fusion - groupupdate core
#				- zsh color change
#
#   V1.0 2021-07-09 RTM:
#       - Upgrade for Gnome 40
#       - Upgrade for Fedora 34
#       - Fix vivaldi
#       - Fix tamviewer package
#       - Fix nordvpn
#       - Tested full automated deploy with success
#       - NordVPN outside default script
#
# TODO:


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

# Disable wayland
sudo sed -i 's/\#WaylandEnable\=false/WaylandEnable\=false/' /etc/gdm/custom.conf

# Grub2 config - Save last option
# sudo runuser -l  root -c 'echo "GRUB_DEFAULT=saved" >> /etc/default/grub'
# sudo runuser -l  root -c 'echo "GRUB_SAVEDEFAULT=true" >> /etc/default/grub'
# sudo grub2-editenv create
# sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Increase fedora package manager speed
sudo runuser -l  root -c 'echo "max_parallel_downloads=15" >> /etc/dnf/dnf.conf'
sudo runuser -l  root -c 'echo "fastestmirror=True" >> /etc/dnf/dnf.conf'

# Update / upgrade
sudo dnf update -y

# Install rpm fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core

# Install the packages from fedora repo
sudo dnf install -y zsh vlc clementine breeze-cursor-theme vim nmap blender gconf-editor brasero gparted wireshark tmux curl vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python3-pip gnome-tweaks snapd gtk-murrine-engine gtk2-engines gnome-tweaks krita frei0r-plugins audacity filezilla tree remmina nload arc-theme chrome-gnome-shell gnome-menus pwgen sysstat alacarte alacritty fzf ffmpeg neofetch util-linux-user grub-customizer xclip flameshot unrar bat gawk net-tools coreutils ncdu whois pdfshuffler piper lsd openssl timeshift  adb fastboot materia-gtk-theme xournal scrot mpv

# Aditional fedora packages
## Plugins Core
sudo dnf -y install dnf-plugins-core

# Brew
bash desktop/source/any/brew.sh

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

# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade

# Flatpack
bash desktop/source/gnome/flatpak.sh
bash desktop/source/any/flatpak.sh

## Install Teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo dnf -y install teamviewer.x86_64.rpm
rm teamviewer.x86_64.rpm
sudo sed -i 's/failovermethod\=priority//' /etc/yum.repos.d/teamviewer.repo

#Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome-stable_current_x86_64.rpm
sudo dnf install -y /tmp/google-chrome-stable_current_x86_64.rpm

# Install Vivaldi
sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf install -y vivaldi-stable

## Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# VIM
bash desktop/source/any/vim.sh

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

# Themes
bash desktop/source/gnome/themes.sh


# Colorls
sudo dnf install -y ruby ruby-devel
sudo gem install colorls

# Droidcam
cd /tmp/
sudo dnf install -y libappindicator-gtk3
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.2.zip
unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client
sudo ./install-video

# Install cargo / rust / lsd
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
cargo install lsd

# Install distrobox
sudo dnf install -y distrobox

# Install ClamAV
sudo dnf install -y clamav clamtk
# sudo dnf install -y clamav-daemon

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
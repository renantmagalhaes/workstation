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

#User check
#echo "#########################"
#echo "#			#"
#echo "#	User Config	#"
#echo "#			#"
#echo "#########################"

#echo "Enter your default user name:"
#read user


# Grub2 config - Save last option
# sudo runuser -l  root -c 'echo "GRUB_DEFAULT=saved" >> /etc/default/grub'
# sudo runuser -l  root -c 'echo "GRUB_SAVEDEFAULT=true" >> /etc/default/grub'
# sudo grub2-editenv create
# sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Increase fedora package manager speed
sudo runuser -l  root -c 'echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf'

# Update / upgrade
sudo dnf update -y

# Install rpm fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core

# Install the packages from fedora repo
sudo dnf install -y zsh vlc clementine breeze-cursor-theme vim nmap blender gconf-editor brasero gparted wireshark tmux curl vpnc x2goclient git idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python3-pip snapd gtk-murrine-engine gtk2-engines krita audacity filezilla tree remmina nload arc-theme pwgen sysstat alacarte fzf ffmpeg neofetch util-linux-user grub-customizer xclip flameshot unrar bat gawk net-tools coreutils ncdu whois pdfshuffler piper lsd openssl gnome-keyring kvantum timeshift

# kde workspace
sudo dnf groupinstall -y "KDE Plasma Workspaces"

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

# Enable BT FastConnectable
sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade

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

## MkCron
sudo snap install mkcron

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

# SDDM
# ## 
# wget https://github.com/renantmagalhaes/workstation/raw/static-files/sddm/sugar-candy.tar.gz -O /tmp/sugar-candy.tar.gz
# sudo tar -xzvf /tmp/sugar-candy.tar.gz -C /usr/share/sddm/themes

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

# Colorls
sudo dnf install -y ruby ruby-devel
sudo gem install colorls

# Install ClamAV
sudo dnf install -y clamav clamtk
# sudo dnf install -y clamav-daemon

# # Remove titlebar when maximized window
# kwriteconfig5 --file ~/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
# qdbus-qt5 org.kde.KWin /KWin reconfigure

# # Latte dock remap key
# kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta  "org.kde.lattedock,/Latte,org.kde.LatteDock,activateLauncherMenu"
# qdbus-qt5 org.kde.KWin /KWin reconfigure

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
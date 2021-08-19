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
#       - Initial release for OpenSUSE Tumbleweed
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

#User check
#echo "#########################"
#echo "#			           #"
#echo "#	  User Config      #"
#echo "#			           #"
#echo "#########################"


# Update / upgrade
sudo zypper refresh && sudo zypper update

# Install OPI
sudo zypper install -y opi

# Kvantum
sudo zypper ar obs://home:trmdi trmdi
sudo zypper in -r trmdi kvantum

# Install the packages from fedora repo
sudo zypper install -y zsh vlc clementine vim nmap blender brasero gparted wireshark tmux curl vpnc git htop meld openvpn guake python3-pip gtk2-engines krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar bat gawk net-tools coreutils ncdu whois piper openssl gnome-keyring timeshift

## multimedia codecs
sudo opi codecs

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install snap
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install -y snapd
source /etc/profile
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

#Utils
# # Enable BT FastConnectable
# sudo sed -i 's/\#FastConnectable\ =\ false/FastConnectable\ =\ true/' /etc/bluetooth/main.conf

# Install pip packages and python path fix
# sudo ln -s /usr/bin/python3 /usr/bin/python
# sudo ln -s /usr/bin/python3.9 /usr/bin/python3
# sudo ln -s /usr/bin/pip3 /usr/bin/pip
sudo pip3 install wheel
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
sudo opi teamviewer

#Install Google Chrome
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub -O /tmp/linux_signing_key.pub
sudo rpm --import /tmp/linux_signing_key.pub
sudo zypper ref
sudo zypper install -y google-chrome-stable


# Install Vivaldi
# sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
# sudo zypper in vivaldi-stable
sudo opi vivaldi

## Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

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
sudo zypper install -y ruby ruby-devel ruby nodejs git gcc make libopenssl-devel sqlite3-devel
sudo gem install colorls

# Install LSD
curl https://sh.rustup.rs -sSf | sh
~/.cargo/bin/cargo install lsd

# Install ClamAV
sudo zypper install -y clamav clamtk
# sudo dnf install -y clamav-daemon

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
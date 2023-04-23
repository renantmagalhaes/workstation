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

# # Check Window System
# if [[ $XDG_SESSION_TYPE == "wayland" ]] ; then
#     echo "Wayland detected. Please change to x11 before running this script"
#     exit 1
# elif [[ $XDG_SESSION_TYPE == "x11" ]] ; then
#      echo "x11 detect."
# else
#     echo "Not able to identify the system"
#     exit 1
# fi

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
# sudo zypper ar obs://home:trmdi trmdi
# sudo zypper in -r trmdi kvantum
sudo zypper install -y kvantum-qt5

# Install the packages from fedora repo
sudo zypper install -y zsh vlc clementine vim nmap blender brasero gparted wireshark curl vpnc git htop meld openvpn guake python3-pip gtk2-engines krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar bat gawk net-tools coreutils ncdu whois piper openssl gnome-keyring timeshift latte-dock virtualbox droidcam android-tools telnet openssh materia-gtk-theme alacritty scrot net-tools-deprecated xprop wmctrl xdotool gcc-c++

# virtualbox users
sudo usermod -aG vboxusers $USER
#sudo gpasswd -a $USER vboxusers

# Brew
bash desktop/source/any/brew.sh

# Temporary install Tmux via brew
/home/linuxbrew/.linuxbrew/bin/brew install tmux
sudo ln -s -f /home/linuxbrew/.linuxbrew/bin/tmux /usr/bin/tmux

# Piper group
sudo usermod -aG games $USER

# Openssh config
sudo systemctl start sshd
sudo systemctl enable sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

## multimedia codecs
sudo opi codecs

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install SNAP
wsl_thumbleweed_check=`env |grep WSL |grep -ioh "openSUSE-Tumbleweed"| awk '{print tolower($0)}'`
wsl_leap_check=`env |grep WSL |grep -ioh "openSUSE-Leap"| awk '{print tolower($0)}'`
if [[ $wsl_leap_check == "opensuse-leap" ]]; then
    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_`cat /etc/os-release |grep VERSION_ID |egrep -Eoh '[0-9]{1,3}.[0-9]{1,3}'` snappy
elif [[ $wsl_thumbleweed_check == "opensuse-tumbleweed" ]]; then
    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
fi
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install -y snapd
source /etc/profile
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
## Fix snapd
sudo ln -s /var/lib/snapd/snap /snap

#Utils
# Install pip packages and python path fix
# sudo ln -s /usr/bin/python3.9 /usr/bin/python
# sudo ln -s /usr/bin/python3.9 /usr/bin/python3
# sudo ln -s /usr/bin/pip3 /usr/bin/pip
sudo pip3 install wheel
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade

# Flatpack
bash desktop/source/any/flatpak.sh

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

# Install Edge
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper ar https://packages.microsoft.com/yumrepos/edge microsoft-edge
sudo zypper refresh
sudo zypper install -y microsoft-edge-stable

## Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts.sh

# VIM
bash desktop/source/any/vim.sh

# Themes
bash desktop/source/gnome/themes.sh
bash desktop/source/kde/themes.sh

# Colorls
sudo zypper install -y ruby ruby-devel ruby nodejs git gcc make libopenssl-devel sqlite3-devel
sudo gem install colorls

# Install LSD
curl https://sh.rustup.rs -sSf | sh
~/.cargo/bin/cargo install lsd

# Install ClamAV
sudo zypper install -y clamav clamtk
# sudo dnf install -y clamav-daemon

# Widgets
## Virtual Desktop Bar
#git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git ~/GIT-REPOS/CORE/virtual-desktop-bar
#sh -c "~/GIT-REPOS/CORE/virtual-desktop-bar/scripts/install-dependencies-opensuse.sh"
#cd ~/GIT-REPOS/CORE/virtual-desktop-bar/scripts && ./install-applet.sh
#
### Dash to panel indicator
#git clone https://github.com/psifidotos/latte-indicator-dashtopanel.git ~/GIT-REPOS/CORE/latte-indicator-dashtopanel
#cd ~/GIT-REPOS/CORE/latte-indicator-dashtopanel && kpackagetool5 -i . -t Latte/Indicator
#
### Applets
#sudo zypper install -y  applet-window-title applet-window-buttons applet-window-appmenu


# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

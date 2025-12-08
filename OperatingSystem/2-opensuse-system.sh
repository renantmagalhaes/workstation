#!/bin/sh
#
#
#?Site        :https://insecure.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#
# ---------------------------------------------------------------
#
# This script  will make all the changes in the system and will download / install my most used packages.
#
#
#*  -> Preferred applications
#*      - Web: Vivaldi / Chrome
#*      - Editor: Visual Studio Code / Neovim
#*      - Music: Clementine / YT Music(web)
#*      - Video: VLC
#*      - Terminal: Guake
#*      - File Manager: Nautilus
#*      - Record Desktop: OBS Studio
#*      - Screenshot tool: Flameshot
#
#  --------------------------------------------------------------
#
# RTM

#RTM
# Verifications

## Root check
if [ “$(id -u)” = “0” ]; then
	echo “Dont run this script as root” 2>&1
	exit 1
fi

# Disable packagekit
sudo systemctl stop packagekit
sudo systemctl mask packagekit

# Update / upgrade
sudo zypper refresh && sudo zypper update

# Dotfiles syslink
ln -s -f $PWD/dotfiles/ ~/.dotfiles
mkdir -p ~/.config/sxhkd/sxhkdrc
ln -s -f $PWD/dotfiles/kde/sxhkd/sxhkdrc ~/.config/sxhkd/sxhkdrc

# Install OPI
sudo zypper install -y opi

# Install the packages from suse repo
sudo zypper --non-interactive install -y zsh vlc clementine breeze5-cursors vim nmap blender brasero gparted wireshark tmux curl vpnc git htop meld openvpn guake python3-pip gtk2-engines krita audacity filezilla tree remmina nload pwgen sysstat alacarte fzf ffmpeg neofetch xclip flameshot unrar gawk net-tools coreutils ncdu whois piper openssl gnome-keyring chrome-gnome-shell telnet openssh materia-gtk-theme alacritty scrot libstdc++-devel glibc-static net-tools-deprecated xprop wmctrl xdotool gcc-c++ sassc virtualbox golang npm bc sqlite3 python312-pipx ruby ruby-devel ruby nodejs git gcc make libopenssl-devel sqlite3-devel cifs-utils cron kdeconnect-kde solaar android-tools lsd fd mpv xwininfo xbindkeys rustup libX11-devel libXcursor-devel jgmenu papirus-icon-theme nmon google-noto-sans-cjk-fonts zoxide

# Install yarn 
sudo npm install --global yarn

# Based on DE
gnome_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "GNOME" | awk '{print tolower($0)}')
kde_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "KDE" | awk '{print tolower($0)}')
if [[ $gnome_check == "gnome" ]]; then
	## Themes
	bash ./scripts/gnome-themes.sh
elif [[ $kde_check == "kde" ]]; then
	sudo zypper --non-interactive install -y kvantum-qt6 kvantum-manager kvantum-themes
	bash ./scripts/gnome-themes.sh
  bash ./scripts/kde-themes.sh
else
	echo "Not able to identify desktop environment"
fi

# Virtualization using KVM + QEMU + libvirt
sudo zypper install -y qemu libvirt virt-manager virt-install libvirt-daemon-config-network bridge-utils ovmf
sudo zypper -n install --type pattern kvm_server kvm_tools
sudo systemctl enable libvirtd --now
sudo usermod -aG libvirt $USER

# Patterns
sudo zypper -n install --type pattern devel_basis

# virtualbox user
sudo usermod -aG vboxusers $USER

# Disable SELINUX
sudo bash ./scripts/selinux.sh

## Install Nix
bash ./scripts/nix-install.sh

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f "/etc/profile.d/nix.sh" ]; then
	. "/etc/profile.d/nix.sh"
else
	echo "Nix environment script not found."
	exit 1
fi

# Brew
bash desktop/source/any/brew.sh

# Piper group
sudo usermod -aG games $USER

# Docker
sudo zypper install -y docker docker-compose docker-compose-switch
sudo systemctl enable docker
sudo usermod -G docker -a $USER
sudo systemctl restart docker

# Openssh config
sudo systemctl start sshd
sudo systemctl enable sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

## multimedia codecs
#yes | sudo opi codecs

# Flatpack repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils
pipx install wheel
pipx install virtualenv virtualenvwrapper pylint
pipx install bpytop

# Install Vivaldi Browser
sudo rpm --import https://repo.vivaldi.com/stable/linux_signing_key.pub
sudo zypper ar -cf https://repo.vivaldi.com/stable/rpm/x86_64/ Vivaldi
sudo zypper ref Vivaldi
sudo zypper in -y vivaldi-stable
sudo zypper refresh

# Install Google Chrome
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub -O /tmp/linux_signing_key.pub
sudo rpm --import /tmp/linux_signing_key.pub
sudo zypper ref
sudo zypper install -y google-chrome-stable

## Zen Browser
bash <(curl -s https://updates.zen-browser.app/install.sh)

## Install Visual Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# SCRIPTS
# ## Install Nix
# bash ./scripts/nix-install.sh
#
# if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
# 	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
# elif [ -f "/etc/profile.d/nix.sh" ]; then
# 	. "/etc/profile.d/nix.sh"
# else
# 	echo "Nix environment script not found."
# 	exit 1
# fi
#
# ## Nix packages
# bash ./OperatingSystem/nix-packages.sh

## Brew
bash ./scripts/brew.sh

## Flatpack
bash ./scripts/flatpak.sh
bash ./scripts/gnome-flatpak.sh

## VIM
bash ./scripts/vim.sh

## Fonts
bash ./scripts/fonts.sh

## TMUX
bash ./scripts/tmux.sh

## ZSH
bash ./scripts/zsh.sh

## Kitty
bash ./scripts/kitty.sh

## Guake
guake --restore-preferences ./utils/guake/rtm-guake-setting

## Neofetch
bash ./scripts/neofetch.sh

## Gems
bash ./scripts/gems.sh

## Rust
bash ./scripts/rust.sh

## GIT
bash ./utils/git-config/git-config.sh

## Polybar
sudo zypper install -y polybar mpd wmctrl playerctl xsel
ln -s -f $PWD/.dotfiles/kde/polybar/ ~/.config/

## jgmenu config
#rm -rf ~/.config/jgmenu/
ln -s -f $PWD/dotfiles/kde/jgmenu ~/.config/

## KDE Tilling window setup
bash ./scripts/kde-DE-transformation.sh

# fd - ignore NFS
bash ./scripts/fd-ignore.sh

# Install ClamAV
sudo zypper install -y clamav clamtk

#Distrobox
#https://github.com/89luca89/distrobox#installation

# ## Droidcam
# bash ./scripts/droidcam.sh

# Cleanup system
## Define max number of snapshots https://en.opensuse.org/SDB:Cleanup_system
# sudo snapper set-config SPACE_LIMIT=0.2 NUMBER_LIMIT=2-6 NUMBER_LIMIT_IMPORTANT=4

##Isolate Alt-Tab workspaces
#gsettings set org.gnome.shell.app-switcher current-workspace-only true

# Change to ZSH
zsh

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         insecure.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
bash

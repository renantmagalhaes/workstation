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
sudo dnf install -y zsh vlc clementine breeze-cursor-theme vim nmap blender gconf-editor brasero gparted wireshark tmux curl vpnc x2goclient git gnome-icon-theme idle3 numix-gtk-theme numix-icon-theme htop meld openvpn guake python3-pip gnome-tweaks snapd gtk-murrine-engine gtk2-engines gnome-tweaks krita frei0r-plugins audacity filezilla tree remmina nload arc-theme chrome-gnome-shell gnome-menus pwgen sysstat alacarte gnome-extensions-app alacritty fzf ffmpeg neofetch util-linux-user grub-customizer xclip flameshot unrar bat gawk net-tools coreutils ncdu whois pdfshuffler piper lsd openssl timeshift  adb fastboot materia-gtk-theme xournal

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

# Flat-remix Theme
# sudo dnf copr enable -y daniruiz/flat-remix
# sudo dnf install -y flat-remix-gnome  flat-remix-gtk2-theme flat-remix-gtk3-theme flat-remix-icon-theme

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

## WhiteSur-gtk-theme
sudo dnf install -y sassc optipng inkscape glib2-devel
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ~/GIT-REPOS/CORE/WhiteSur-gtk-theme
sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/install.sh -i void -N mojave -c dark -c light -t all 
# sudo ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/tweaks.sh -g 

# Fluent Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git ~/GIT-REPOS/CORE/Fluent-gtk-theme
sh -c "~/GIT-REPOS/CORE/Fluent-gtk-theme/install.sh"

git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/GIT-REPOS/CORE/Fluent-icon-theme
sh -c "~/GIT-REPOS/CORE/Fluent-icon-theme/install.sh"
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist /usr/share/icons/Fluent-cursors
sudo cp -r ~/GIT-REPOS/CORE/Fluent-icon-theme/cursors/dist-dark /usr/share/icons/Fluent-dark-cursors

# Dracula theme
wget https://github.com/dracula/gtk/archive/master.zip -O ~/.themes/Dracula.zip
unzip ~/.themes/Dracula.zip -d ~/.themes/Dracula
mv ~/.themes/Dracula/gtk-master/* ~/.themes/Dracula

# Matcha Theme
git clone https://github.com/vinceliuice/Matcha-gtk-theme.git ~/GIT-REPOS/CORE/Matcha-gtk-theme
sh -c "~/GIT-REPOS/CORE/Matcha-gtk-theme/install.sh"

# Tela-circle-icon-theme
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git ~/GIT-REPOS/CORE/Tela-circle-icon-theme
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh blue"
sh -c "~/GIT-REPOS/CORE/Tela-circle-icon-theme/install.sh black"

# Tela-icon-theme
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

## Dock icon 
#mv ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid.svg ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid-backup.svg
#cp  ~/GIT-REPOS/CORE/WhiteSur-gtk-theme/src/assets/gnome-shell/activities-black/activities-void.svg ~/.local/share/icons/Flatery-Indigo-Dark/actions/16/view-grid.svg


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

# Droidcam
cd /tmp/
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.0.zip
unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client
sudo ./install-video

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
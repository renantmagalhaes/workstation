#!/bin/bash
# TODO:

########### MAC OS APPS ###########
macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`

if [[ $macos_check == "darwin" ]]; then
    brew install --cask pgadmin4
    # brew install --cask robo-3t ### OUTDATED ?
    brew install --cask dbeaver-community
    brew install --cask postman

    exit
fi

########### WINDOWS APPS ###########
# Default folder
mkdir -p ~/Apps

#Mindmap
# sudo flatpak install -y flathub net.xmind.XMind8
# sudo flatpak override --filesystem=home:ro net.xmind.XMind8
sudo flatpak install -y flathub net.xmind.ZEN
sudo flatpak override --filesystem=home:ro net.xmind.ZEN

# Redis
sudo flatpak install -y flathub dev.rdm.RDM
#sudo snap install redis-desktop-manager
#wget https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.3.9/Another-Redis-Desktop-Manager.1.3.9.AppImage -O ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
#chmod +x ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
##! Add this program in menu using Alacarte package

# DBeaver
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

# Postman
sudo flatpak install -y flathub com.getpostman.Postman

# Regex tester
sudo flatpak install -y flathub com.github.artemanufrij.regextester

# jPdfTweak
sudo flatpak install -y flathub net.sourceforge.jpdftweak.jPdfTweak

# K8S IDE - Lens
# sudo snap install kontena-lens --classic

# scrcpy
# sudo snap install scrcpy

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"
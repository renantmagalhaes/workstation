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

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd nix-env; then # FOR NIX PKG MANAGER

    export NIXPKGS_ALLOW_UNFREE=1

    nix-env -iA \
    nixpkgs.robo3t \
    nixpkgs.pgadmin4 \
    nixpkgs.scrcpy

    
else
    echo "Nix package manager not installed, go to https://nixos.org/download"
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


#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"

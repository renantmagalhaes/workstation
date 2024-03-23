#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd nix-env; then # FOR NIX PKG MANAGER

    # startup
    nix-shell -p nix-info --run "nix-info -m"
    
    # allow unfree
    export NIXPKGS_ALLOW_UNFREE=1
    
    # install packages
    nix-env -iA \
    nixpkgs.clementine \
    nixpkgs.nmap \
    nixpkgs.blender \
    nixpkgs.powerline-fonts \
    nixpkgs.cantarell-fonts \
    nixpkgs.brasero \
    nixpkgs.wireshark \
    nixpkgs.tmux \
    nixpkgs.curl \
    nixpkgs.nettools \
    nixpkgs.iproute2 \
    nixpkgs.vpnc-scripts \
    nixpkgs.vpnc \
    nixpkgs.networkmanagerapplet \
    nixpkgs.git \
    nixpkgs.htop \
    nixpkgs.meld \
    nixpkgs.dconf \
    nixpkgs.openvpn \
    nixpkgs.frei0r \
    nixpkgs.audacity \
    nixpkgs.filezilla \
    nixpkgs.ffmpeg \
    nixpkgs.nload \
    nixpkgs.sysstat \
    nixpkgs.fzf \
    nixpkgs.ffmpeg \
    nixpkgs.neofetch \
    nixpkgs.xclip \
    nixpkgs.flameshot \
    nixpkgs.bat \
    nixpkgs.gawk \
    nixpkgs.coreutils \
    nixpkgs.gnome.cheese \
    nixpkgs.ncdu \
    nixpkgs.whois \
    nixpkgs.piper \
    nixpkgs.libratbag \
    nixpkgs.timeshift \
    nixpkgs.android-tools \
    nixpkgs.materia-theme \
    nixpkgs.xournal \
    nixpkgs.jp2a \
    nixpkgs.unrar \
    nixpkgs.dnsutils \
    nixpkgs.imagemagick \
    nixpkgs.scrot \
    nixpkgs.wmctrl \
    nixpkgs.xdotool \
    nixpkgs.lsd \
    nixpkgs.xournal \
    nixpkgs.evince \
    nixpkgs.jq \
    nixpkgs.pulseaudio \
    nixpkgs.colorls \
    nixpkgs.droidcam
        
    else
    echo "Nix package manager not installed, go to https://nixos.org/download"
    exit
fi




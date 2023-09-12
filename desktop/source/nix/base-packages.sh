#!/bin/bash

# startup
nix-shell -p nix-info --run "nix-info -m"

# allow unfree
export NIXPKGS_ALLOW_UNFREE=1

# install packages
nix-env -iA \
nixpkgs.clementine \
nixpkgs.vim \
nixpkgs.zsh \
nixpkgs.nmap \
nixpkgs.blender \
nixpkgs.powerline-fonts \
nixpkgs.cantarell-fonts \
nixpkgs.brasero \
nixpkgs.gparted \
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
nixpkgs.krita \
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
nixpkgs.lm_sensors \
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
nixpkgs.alacritty \
nixpkgs.scrot \
nixpkgs.wmctrl \
nixpkgs.xdotool \
nixpkgs.lsd \
nixpkgs.xournal \
nixpkgs.evince \
nixpkgs.jq \
nixpkgs.pulseaudio \
nixpkgs.vscode \
nixpkgs.colorls \
nixpkgs.droidcam


#!/bin/bash

# Source Nix environment variables to the current shell
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f "/etc/profile.d/nix.sh" ]; then
	. "/etc/profile.d/nix.sh"
else
	echo "Nix environment script not found."
	exit 1
fi

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

# Add the repository key with either wget or curl
if check_cmd nix-env; then # FOR NIX PKG MANAGER

	# startup
	nix-shell -p nix-info --run "nix-info -m"

	# allow unfree
	export NIXPKGS_ALLOW_UNFREE=1

	# install packages
	nix-env -iA \
		nixpkgs.zsh \
		nixpkgs.vlc \
		nixpkgs.clementine \
		nixpkgs.capitaine-cursors \
		nixpkgs.apple-cursor \
		nixpkgs.comixcursors \
		nixpkgs.apple-cursor \
		nixpkgs.afterglow-cursors-recolored \
		nixpkgs.vim \
		nixpkgs.nmap \
		nixpkgs.blender \
		nixpkgs.powerline-fonts \
		nixpkgs.cantarell-fonts \
		nixpkgs.brasero \
		nixpkgs.wireshark \
		nixpkgs.gparted \
		nixpkgs.tmux \
		nixpkgs.python3 \
		nixpkgs.pipx \
		nixpkgs.gtk_engines \
		nixpkgs.krita \
		nixpkgs.nettools \
		nixpkgs.iproute2 \
		nixpkgs.remmina \
		nixpkgs.vpnc-scripts \
		nixpkgs.pwgen \
		nixpkgs.vpnc \
		nixpkgs.networkmanagerapplet \
		nixpkgs.tree \
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
		nixpkgs.alacarte \
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
		nixpkgs.openssl \
		nixpkgs.inetutils \
		nixpkgs.libratbag \
		nixpkgs.timeshift \
		nixpkgs.android-tools \
		nixpkgs.materia-theme \
		nixpkgs.xournal \
		nixpkgs.jp2a \
		nixpkgs.unrar \
		nixpkgs.dnsutils \
		nixpkgs.kitty \
		nixpkgs.imagemagick \
		nixpkgs.scrot \
		nixpkgs.wmctrl \
		nixpkgs.xdotool \
		nixpkgs.xorg.xprop \
		nixpkgs.lsd \
		nixpkgs.go \
		nixpkgs.libgcc \
		nixpkgs.glibc \
		nixpkgs.libstdcxx5 \
		nixpkgs.scrcpy \
		nixpkgs.bc \
		nixpkgs.git-extras \
		nixpkgs.fd \
		nixpkgs.nodejs_20 \
		nixpkgs.sqlite \
		nixpkgs.cinnamon.nemo \
		nixpkgs.sassc \
		nixpkgs.virtualbox \
		nixpkgs.ripgrep \
		nixpkgs.lazygit \
		nixpkgs.xournal \
		nixpkgs.neovim \
		nixpkgs.evince \
		nixpkgs.jq \
		nixpkgs.pulseaudio \
		nixpkgs.lm_sensors \
		nixpkgs.gnome.cheese \
		nixpkgs.colorls \
		nixpkgs.clamav \
		nixpkgs.clamtk \
		nixpkgs.gir-rs \
		nixpkgs.teamviewer \
		nixpkgs.droidcam

else
	echo "Nix package manager not installed, go to https://nixos.org/download"
	exit
fi

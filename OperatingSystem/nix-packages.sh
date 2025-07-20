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
		nixpkgs.capitaine-cursors \
		nixpkgs.apple-cursor \
		nixpkgs.comixcursors \
		nixpkgs.apple-cursor \
		nixpkgs.afterglow-cursors-recolored \
		nixpkgs.powerline-fonts \
		nixpkgs.cantarell-fonts \
		nixpkgs.lsd \
		nixpkgs.fd \
		nixpkgs.colorls \
		nixpkgs.mpv \
		nixpkgs.xcolor \
		nixpkgs.imagemagick \
		nixpkgs.xwinwrap \
		nixpkgs.zoxide

else
	echo "Nix package manager not installed, go to https://nixos.org/download"
	exit
fi

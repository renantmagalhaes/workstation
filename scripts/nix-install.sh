#!/bin/bash

# Install Nix package manager
## Multi-user
sh <(curl -L https://nixos.org/nix/install) --daemon
## Single-user
# sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Source Nix environment variables to the current shell
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f "/etc/profile.d/nix.sh" ]; then
	. "/etc/profile.d/nix.sh"
else
	echo "Nix environment script not found."
	exit 1
fi

# If ssl error
#echo "ssl-cert-file = /etc/ssl/ca-bundle.pem" | sudo tee -a /etc/nix/nix.conf

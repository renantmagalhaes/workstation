#!/bin/bash

check_cmd() {
	command -v "$1" 2>/dev/null
}

# Check if fish is installed
if check_cmd fish; then # FOR DEB SYSTEMS
	echo "fish shell detected"
else
	# Install fish
	brew install fish
fi

# Install OMF (Oh my fish)
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

#!/bin/bash

macos_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')
linux_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

if check_cmd sw_vers; then # FOR MACOS SYSTEMS
	if [[ $macos_check == "darwin" ]]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		echo '# Set PATH, MANPATH, etc., for Homebrew.' >>/Users/$USER/.zprofile
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/$USER/.zprofile
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else
		echo "Not able to identify desktop environment"
	fi
else
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>/home/rtm/.zprofile
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>/home/rtm/.profile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install neovim
brew install neovim

# Install bat
brew install bat

# Install git-delta
brew install git-delta

# Ripgrep
brew install ripgrep

# Lazygit
brew install lazygit

# LazyDocker
brew install jesseduffield/lazydocker/lazydocker

# Fish shell
brew install fish

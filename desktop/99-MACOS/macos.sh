#!/bin/sh
#
#
#?Site        :https://rtm.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#

#Root check
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi

# Brew
bash desktop/source/any/brew.sh

# Default packages
brew install wget \tree \htop \iterm2 \tmux

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fonts
bash desktop/source/any/fonts-macos.sh

# VIM
bash desktop/source/any/vim.sh

# ColorLS
brew install ruby
sudo gem install colorls

# LSD
brew install lsd

# Tilling Window
brew install --cask amethyst

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
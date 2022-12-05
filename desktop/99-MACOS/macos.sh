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
brew install wget \tree \htop \iterm2 \tmux \go \neofetch \rectangle \coreutils

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

# OBS
brew install --cask obs

# System settings
## MacOS use dimmed icons for hidden applications
defaults write com.apple.Dock showhidden -boolean yes
## Revert
#defaults write com.apple.Dock showhidden -boolean no; killall Dock

## make animation when hiding or showing dock much faster
defaults write com.apple.dock autohide-time-modifier -float 0.15
## Revert
#defaults delete com.apple.dock autohide-time-modifier;killall Dock

## Reduce delay to activate dock
defaults write com.apple.Dock autohide-delay -float 0.05

## Restart dock
killall Dock

## Disabling Time Machine Use New Drive Setup Requests in Mac OS X
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
## Revert
#defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool false

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
#!/bin/bash
# remove folder
rm -rf ~/.config/neofetch

# Create link
ln -s -f $PWD/dotfiles/neofetch ~/.config/neofetch

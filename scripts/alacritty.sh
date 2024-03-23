#!/bin/bash

# Create folder
mkdir -p ~/.config/alacritty/

echo "$PWD alacritty.sh"
# syslink to file
ln -s -f $PWD/dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

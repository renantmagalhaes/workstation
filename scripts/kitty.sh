#!/bin/bash

# Create folder
rm -rf ~/.config/kitty/

# syslink to file
ln -s -f $PWD/dotfiles/kitty ~/.config/kitty

#!/bin/bash
# remove folder
rm -rf ~/.config/neofetch

# Create link
ln -s -f $PWD/config/neofetch ~/.config/neofetch
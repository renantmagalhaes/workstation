#!/bin/bash

# Create folder
mkdir -p ~/.config/alacritty/

# syslink to file
ln -s -f $PWD/config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

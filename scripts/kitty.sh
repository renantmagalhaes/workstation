#!/bin/bash

# install latest
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    launch=n

# syslink 
ls -s -f ~/.local/kitty.app/bin/kitty /usr/bin/kitty

# Create folder
rm -rf ~/.config/kitty/

# syslink to file
ln -s -f $PWD/dotfiles/kitty ~/.config/kitty

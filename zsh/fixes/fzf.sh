#!/bin/bash

#####################
#  Fix missing fzf  #
#####################

# Download git and install
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Create default path folder
sudo mkdir -p /usr/share/fzf/shell/

# Copy keybinding
sudo cp key-bindings.zsh /usr/share/fzf/shell/
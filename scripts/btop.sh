#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create folder
mkdir -p ~/.config/btop/

# syslink to file
ln -s -f "$REPO_DIR/dotfiles/btop/btop.conf" ~/.config/btop/btop.conf

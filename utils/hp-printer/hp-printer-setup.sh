#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y install hplip xsane sane
    hp-setup
elif check_cmd dnf; then
    sudo dnf install -y hplip xsane sane hplip-gui
    hp-setup
else
    echo "system not found"
    fi

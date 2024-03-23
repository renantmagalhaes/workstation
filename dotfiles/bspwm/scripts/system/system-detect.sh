#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

if check_cmd apt-get; then # FOR DEB SYSTEMS
    # polkit
    # mate-polkit &
    echo "deb"
    
elif check_cmd dnf; then  # FOR RPM SYSTEMS
    echo "fedora"
else
    echo "Not able to identify the system" > ~/bspwm.log
fi
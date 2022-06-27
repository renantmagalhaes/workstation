#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS

    sudo apt-get install -y sqlitebrowser

elif check_cmd dnf; then  # FOR RPM SYSTEMS

    sudo dnf install -y sqlitebrowser


elif check_cmd zypper; then  # FOR RPM SYSTEMS

    sudo zypper install -y sqlitebrowser

else
    echo "Not able to identify the system"
fi

# Burp
wget https://portswigger.net/burp/releases/startdownload?product=community&version=2022.5.2&type=Linux -O /tmp/burp.sh
chmod +x /tmp/burp.sh
sh -c "/tmp/burp.sh"
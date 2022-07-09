#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if check_cmd apt-get; then # FOR DEB SYSTEMS

    # Get virtualbox Version
    VERSION=$(vboxmanage --version |grep -oh ^[0-9].[0-9].[0-9]*)

    # Download ext pack
    wget https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack -O /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack

    # Install
    virtualbox /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &

elif check_cmd dnf; then  # FOR RPM SYSTEMS

    # Get virtualbox Version
    VERSION=$(vboxmanage --version |grep -oh ^[0-9].[0-9].[0-9]*)

    # Download ext pack
    wget https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack -O /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack

    # Install
    virtualbox /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &

elif check_cmd zypper; then  # FOR RPM SYSTEMS

    # Get virtualbox Version
    VERSION=$(VBoxManage --version |grep -oh ^[0-9].[0-9].[0-9]*)

    # Download ext pack
    wget https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack -O /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack

    # Install
    VirtualBox /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &


elif check_cmd pacman; then  # FOR RPM SYSTEMS

    echo "Coming soon"

fi
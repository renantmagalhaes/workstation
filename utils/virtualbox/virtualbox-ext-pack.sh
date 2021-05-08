#!/bin/bash

# Get virtualbox Version
VERSION=$(vboxmanage --version |grep -oh ^[0-9].[0-9].[0-9]*)

# Download ext pack
wget https://download.virtualbox.org/virtualbox/$VERSION/Oracle_VM_VirtualBox_Extension_Pack-$VERSION.vbox-extpack -O /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack

# Install
virtualbox /tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack &
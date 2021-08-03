#!/bin/bash

# Dependencies
sudo dnf -y install @development-tools
sudo dnf -y install kernel-headers kernel-devel dkms elfutils-libelf-devel qt5-qtx11extras

# Repository
source /etc/os-release

cat <<EOF | sudo tee /etc/yum.repos.d/virtualbox.repo 
[virtualbox]
name=Fedora $releasever - $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/$VERSION_ID/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc
EOF

# Installation
sudo dnf search virtualbox
sudo dnf install -y VirtualBox-6.1
sudo usermod -a -G vboxusers $USER
newgrp vboxusers
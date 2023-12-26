#!/bin/bash
# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

if check_cmd apt-get; then # FOR DEB SYSTEMS

    # add public GPG
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
    echo "deb http://apt.insync.io/$(cat /etc/os-release | egrep ^ID | cut -f2 -d"=") $(cat /etc/os-release | grep VERSION_CODENAME | cut -f2 -d"=") non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list
    sudo apt-get update
    sudo apt-get install insync -y


elif check_cmd zypper; then  # FOR RPM SYSTEMS
    # add public GPG
    sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key

    # Add repo
    sudo zypper ar -f http://yum.insync.io/opensuse-tumbleweed/rolling/ Insync

    # Install Insync
    sudo zypper refresh
    sudo zypper install insync

else
    echo "Not able to identify the system"
fi

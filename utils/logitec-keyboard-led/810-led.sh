#!/bin/bash
#https://github.com/MatMoul/g810-led


check_cmd() {
    command -v "$1" 2> /dev/null
}


# Download Dependencies

if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y git g++ make libhidapi-dev # for hidapi
    sudo apt-get install -y git g++ make libusb-1.0-0-dev # for libusb

elif check_cmd dnf; then  # FOR RPM SYSTEMS
    sudo dnf install -y git make gcc-c++ hidapi-devel # for hidapi
    sudo dnf install -y git make gcc-c++ libusbx-devel

elif check_cmd zypper; then  # FOR SUSE SYSTEMS
    sudo zypper install -y git make  gcc-c++ libhidapi-devel # for hidapi
    sudo zypper install -y git make gcc-c++ libusb-1_0-devel
elif check_cmd pacman; then  # FOR Arch SYSTEMS
    sudo pacman -Sy git gcc make hidapi # for hidapi
    sudo pacman -Sy git gcc make libusb # for libusb
else 
    echo "Not able to identify the system"
fi


# Install program

git clone https://github.com/MatMoul/g810-led.git ~/GIT-REPOS/CORE/g810-led
cd ~/GIT-REPOS/CORE/g810-led
make bin # for hidapi
# make bin LIB=libusb # for libusb
sudo make install


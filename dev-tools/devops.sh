#!/bin/bash

check_cmd() {
    command -v "$1" 2> /dev/null
}


# Ansible
sudo pip3 install ansible
sudo pip3 install "ansible-lint[yamllint]"
sudo pip3 install argcomplete


if check_cmd apt-get; then # FOR DEB SYSTEMS

    
elif check_cmd dnf; then  # FOR RPM SYSTEMS


elif check_cmd zypper; then  # FOR RPM SYSTEMS

    echo "Not able to identify the system"
fi

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"








sudo pip3 install "ansible-lint[yamllint]"
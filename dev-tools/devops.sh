#!/bin/bash

check_cmd() {
    command -v "$1" 2> /dev/null
}


# Ansible
sudo pip3 install ansible
sudo pip3 install "ansible-lint[yamllint]"
sudo pip3 install argcomplete


if check_cmd apt-get; then # FOR DEB SYSTEMS
    # Terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt install -y terraform
    
elif check_cmd dnf; then  # FOR RPM SYSTEMS
    # Terraform
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install -y terraform  

elif check_cmd zypper; then  # FOR RPM SYSTEMS
    # Terraform
    sudo zypper install -y terraform

    echo "Not able to identify the system"
fi

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"
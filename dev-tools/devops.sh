#!/bin/bash

check_cmd() {
    command -v "$1" 2> /dev/null
}

# AWS 
cd /tmp/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

## EKS

### aws-iam-authenticator
brew install aws-iam-authenticator

### eksctl
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl


# Ansible
sudo pip3 install ansible
sudo pip3 install "ansible-lint[yamllint]"
sudo pip3 install argcomplete

# Skaffold
brew install skaffold

# ArgoCD
brew install argocd

#FluxCD
brew install fluxcd/tap/flux

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
    # sudo zypper install -y terraform
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform


    echo "Not able to identify the system"
fi

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"
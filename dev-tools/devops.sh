#!/bin/bash

type brew >/dev/null 2>&1 || { echo >&2 "The brew cli is required for this script to run."; exit 1; }

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

### kubectl
brew install kubectl

# Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Ansible
sudo pip3 install ansible
sudo pip3 install "ansible-lint[yamllint]"
sudo pip3 install argcomplete

# Skaffold
brew install skaffold

# ArgoCD
brew install argocd

# FluxCD
brew install fluxcd/tap/flux

# popeye
brew install derailed/popeye/popeye

# kubescape
curl -s https://raw.githubusercontent.com/armosec/kubescape/master/install.sh | /bin/bash


if check_cmd apt-get; then # FOR DEB SYSTEMS
    neofetch
elif check_cmd dnf; then  # FOR RPM SYSTEMS
    neofetch
elif check_cmd zypper; then  # FOR SUSE SYSTEMS
    neofetch
elif check_cmd pacman; then  # FOR Arch SYSTEMS
    neofetch
else 
    echo "Not able to identify the system"
fi

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"

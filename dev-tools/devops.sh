#!/bin/bash

type brew >/dev/null 2>&1 || { echo >&2 "The brew cli is required for this script to run."; exit 1; }

macos_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`
linux_check=`uname -a |awk '{print $1}' | awk '{print tolower($0)}'`


check_cmd() {
    command -v "$1" 2> /dev/null
}


if [[ $macos_check == "darwin" ]]; then
    # AWS CLI
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /

elif [[ $linux_check == "linux" ]]; then
    # AWS CLI
    cd /tmp/
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

else
    echo "System not detected ... exiting"
    exit
fi

## EKS
### aws-iam-authenticator
brew install aws-iam-authenticator

### eksctl
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl

### kubectl
brew install kubectl


if check_cmd apt-get; then # FOR DEB SYSTEMS
    neofetch
elif check_cmd dnf; then  # FOR RPM SYSTEMS
    neofetch
elif check_cmd zypper; then  # FOR SUSE SYSTEMS
    neofetch
elif check_cmd pacman; then  # FOR Arch SYSTEMS
    neofetch
elif check_cmd sw_vers; then  # FOR Arch SYSTEMS
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

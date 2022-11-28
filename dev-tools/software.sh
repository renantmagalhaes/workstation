#!/bin/bash
# TODO:
#//  - Check if Deb or RPM distribution

# Default folder
mkdir -p ~/Apps

#Mindmap
# sudo flatpak install -y flathub net.xmind.XMind8
# sudo flatpak override --filesystem=home:ro net.xmind.XMind8
sudo flatpak install -y flathub net.xmind.ZEN
sudo flatpak override --filesystem=home:ro net.xmind.ZEN

# Redis
sudo flatpak install -y flathub dev.rdm.RDM
#sudo snap install redis-desktop-manager
#wget https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.3.9/Another-Redis-Desktop-Manager.1.3.9.AppImage -O ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
#chmod +x ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
##! Add this program in menu using Alacarte package

# Restart snapd service
sudo systemctl restart snapd.seeded.service

# Robo3t
sudo snap install robo3t-snap

# DBeaver
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

# Postman
sudo flatpak install -y flathub com.getpostman.Postman

# Regex tester
sudo flatpak install -y flathub com.github.artemanufrij.regextester

# jPdfTweak
sudo flatpak install -y flathub net.sourceforge.jpdftweak.jPdfTweak

# K8S IDE - Lens
# sudo snap install kontena-lens --classic

# RPM OR DEB env

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS
    ## pgAdmin
    sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
    sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
    sudo apt install -y pgadmin4-desktop

    ## docker
    sudo apt install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo systemctl enable docker
    sudo systemctl restart docker
    sudo usermod -aG docker $USER

    ## yarn / Nodejs
    # sudo apt install -y curl gnupg2 make
    # sudo curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    # sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    # sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    # sudo apt update -y
    # sudo apt install -y yarn nodejs

    ## kontena-lens
    wget https://api.k8slens.dev/binaries/Lens-5.2.5-latest.20211001.2.amd64.deb -O /tmp/Lens.deb
    sudo dpkg -i /tmp/Lens.deb
    
elif check_cmd dnf; then  # FOR RPM SYSTEMS

    #pgadmin 
    sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-fedora-repo-2-1.noarch.rpm
    sudo yum install -y pgadmin4

    # docker
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce containerd.io docker-compose docker-compose-plugin
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl restart docker

    ## podman
    # sudo dnf -y install podman podman-compose

    # ## yarn / nodejs
    # sudo dnf install -y curl gnupg2 gcc-c++ make
    # sudo curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
    # sudo curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
    # sudo sed -i 's/failovermethod\=priority//' /etc/yum.repos.d/*
    # sudo dnf update -y
    # sudo dnf install -y yarn nodejs

    # Fix fontissue robo3t
    sudo rm -rf /var/cache/fontconfig/*
    rm -rf ~/.cache/fontconfig/*
    sudo rm -rf ~/snap/robo3t-snap/common/.cache/fontconfig/*
    sudo fc-cache -r

    ## lib dependency
    sudo ln -s /usr/lib64/libcurl.so.4 /usr/lib64/libcurl-gnutls.so.4

elif check_cmd zypper; then  # FOR RPM SYSTEMS
    ## docker
    sudo zypper install -y docker python3-docker-compose
    sudo systemctl enable docker
    sudo usermod -G docker -a $USER
    sudo systemctl restart docker

    ## yarn / nodejs
    sudo zypper install -y yarn nodejs

    #pgadmin4
    # sudo zypper install pgadmin4 pgadmin4-web

    # robo3t
    ## Fix fontissue robo3t
    sudo rm -rf /var/cache/fontconfig/*
    rm -rf ~/.cache/fontconfig/*
    sudo rm -rf ~/snap/robo3t-snap/common/.cache/fontconfig/*
    sudo fc-cache -r
    # wget `curl --silent "https://api.github.com/repos/Studio3T/robomongo/releases/latest" |grep browser_download_url | grep tar.gz |grep -Po '"browser_download_url": "\K.*?(?=")'` -O ~/Apps/robo3t.tar.gz
    # ln -s /usr/lib64/libcurl.so.4 ~/Apps/bin/robo3t-1.4.1/lib/libcurl-gnutls.so.4

elif check_cmd pacman; then 
    ## docker
    yes | sudo pacman -Sy docker docker-compose
    sudo systemctl enable docker
    sudo usermod -G docker -a $USER

    ## pgadmin4
    yes | sudo pacman -Sy pgadmin4
else
    echo "Not able to identify the system"
fi

# scrcpy
sudo snap install scrcpy

#clear
echo "###########################"
echo "#                         #"
echo "#      rtm.codes          #"
echo "#       DONE              #"
echo "#                         #"
echo "###########################"

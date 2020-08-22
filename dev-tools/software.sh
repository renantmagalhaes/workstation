# Postman
sudo flatpak install -y flathub com.getpostman.Postman

# Redis
sudo snap install redis-desktop-manager

# Robo3t
sudo snap install robo3t-snap

# Mysql Workbench
sudo snap install mysql-workbench-community --candidate

# EasySSH
flatpak install -y flathub com.github.muriloventuroso.easyssh

#Mindmap

## XMind Zen
flatpak install -y flathub net.xmind.ZEN

## Xmind8
flatpak install -y flathub net.xmind.XMind8

# DBeaver
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt-get update && sudo apt-get install -y dbeaver-ce

# Install Docker
## Install latest docker
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $USER

## Install Docker Repo Version - Ubuntu
sudo apt install docker docker.io
sudo usermod -aG docker `whoami`

## Install Docker Repo Version - Fedora 32
sudo dnf -y install dnf-plugins-core

sudo tee /etc/yum.repos.d/docker-ce.repo<<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/31/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
sudo dnf makecache
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo usermod -aG docker $(whoami)
newgrp docker
sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd

#Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

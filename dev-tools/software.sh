#Mindmap
## XMind
https://www.xmind.net/download/

# Redis
sudo snap install redis-desktop-manager

# Robo3t
sudo snap install robo3t-snap

# Mysql Workbench
sudo snap install mysql-workbench-community --candidate

# Postman
sudo flatpak install -y flathub com.getpostman.Postman

# DBeaver
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

# Regex tester
sudo flatpak install -y flathub com.github.artemanufrij.regextester

# PyCharm
sudo flatpak install -y flathub com.jetbrains.PyCharm-Community

# jPdfTweak
sudo flatpak install -y flathub net.sourceforge.jpdftweak.jPdfTweak


#Yarn and NodeJs
## Fedora
sudo yum update -y
sudo yum install -y curl gnupg2
sudo curl -sL https://rpm.nodesource.com/setup_12.x | bash -
sudo curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo yum clean all && yum makecache
sudo yum install -y gcc-c++ make
sudo yum install -y yarn nodejs


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
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"

sudo firewall-cmd --zone=FedoraWorkstation --add-masquerade --permanent
sudo firewall-cmd --reload
sudo systemctl restart docker


#Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

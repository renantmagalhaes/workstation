# TODO - Check if Deb or RPM distribution

# Default folder
mkdir -p ~/Apps

#Mindmap
#sudo flatpak install -y flathub net.xmind.XMind8
sudo flatpak install -y flathub net.xmind.ZEN

# Redis
#sudo snap install redis-desktop-manager
wget https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.3.9/Another-Redis-Desktop-Manager.1.3.9.AppImage -O ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
chmod +x ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
#! Add this program in menu using Alacarte package

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
sudo snap install kontena-lens --classic

#Yarn and NodeJs
### Fedora
#sudo dnf install -y curl gnupg2 gcc-c++ make
#sudo curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
#sudo curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
#sudo dnf update -y
#sudo dnf install -y yarn nodejs

## DEB based
sudo apt install -y curl gnupg2 gcc-c++ make
sudo curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update -y
sudo apt install -y yarn nodejs

# Docker

### Fedora
####Install Docker Repo Version - Fedora 33 (Maybe not needed anymore after cgroups update)
#sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
#sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
#sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
#sudo firewall-cmd --reload
#sudo dnf install -y moby-engine docker-compose
#sudo systemctl enable docker
#sudo groupadd docker
#sudo usermod -aG docker $USER
#sudo systemctl restart docker
#
## DEB Based 20.04
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo systemctl enable docker
sudo systemctl restart docker
sudo usermod -aG docker $USER


# Default folder
mkdir -p ~/Apps

#Mindmap
## XMind
https://www.xmind.net/download/

# Redis
#sudo snap install redis-desktop-manager
wget https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.3.9/Another-Redis-Desktop-Manager.1.3.9.AppImage -O ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
chmod +x ~/Apps/Another-Redis-Desktop-Manager.1.3.9.AppImage
#! Add this program in menu using Alacarte package

# Robo3t
sudo snap install robo3t-snap

# DBeaver
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity

# Mysql Workbench
sudo snap install mysql-workbench-community --candidate

# Postman
sudo flatpak install -y flathub com.getpostman.Postman

# Regex tester
sudo flatpak install -y flathub com.github.artemanufrij.regextester

# jPdfTweak
sudo flatpak install -y flathub net.sourceforge.jpdftweak.jPdfTweak

# K8S IDE - Lens
sudo snap install kontena-lens --classic

#Yarn and NodeJs
## Fedora
sudo yum update -y
sudo yum install -y curl gnupg2
sudo curl -sL https://rpm.nodesource.com/setup_12.x | bash -
sudo curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo yum clean all && yum makecache
sudo yum install -y gcc-c++ make
sudo yum install -y yarn nodejs

# Install Docker Repo Version - Fedora 33
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
sudo firewall-cmd --reload
sudo dnf install -y moby-engine docker-compose
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl restart docker
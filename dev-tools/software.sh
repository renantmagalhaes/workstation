#Postman
sudo snap install postman

#Redis
sudo snap install redis-desktop-manager

#Robo3t
sudo snap install robo3t-snap

#Mysql Workbench
sudo snap install mysql-workbench-community --candidate

#Mindmap
## Freemind
sudo snap install freemind

## XMind Zen
wget --user-agent="Mozilla/4.0 (Windows; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)" www.xmind.net/xmind/downloads/XMind-ZEN-for-Linux-64bit.deb -O /tmp/XMind-ZEN-for-Linux-64bit.deb
sudo dpkg -i /tmp/XMind-ZEN-for-Linux-64bit.deb

# DBeaver
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt-get update && sudo apt-get install -y dbeaver-ce

# Install Docker
## Install latest docker
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $USER


#Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

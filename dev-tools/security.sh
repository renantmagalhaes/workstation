#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS

    sudo apt-get install -y golang sqlitebrowser aircrack-ng nmap jq

elif check_cmd dnf; then  # FOR RPM SYSTEMS

    sudo dnf install -y golang sqlitebrowser aircrack-ng nmap jq

else
    echo "Not able to identify the system"
fi

# Legion
# https://github.com/carlospolop/legion

# Burp
wget https://portswigger.net/burp/releases/startdownload?product=community&version=2022.5.2&type=Linux -O /tmp/burp.sh
chmod +x /tmp/burp.sh
sh -c "/tmp/burp.sh"

# Amass
brew tap caffix/amass
brew install amass

# DNS Recon
git clone https://github.com/darkoperator/dnsrecon.git ~/GIT-REPOS/CORE/dnsrecon
cd ~/GIT-REPOS/CORE/dnsrecon && pip3 install -r requirements.txt --no-warn-script-location
sudo ln -s -f  $PWD/dnsrecon.py /usr/local/bin/dnsrecon

# Assetfinder
wget https://github.com/tomnomnom/assetfinder/releases/download/v0.1.1/assetfinder-linux-amd64-0.1.1.tgz -O /tmp/assetfinder.tgz
sudo tar -xzvf /tmp/assetfinder.tgz -C /usr/local/bin/

# Findomain
sudo wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux -O /usr/local/bin/findomain
chmod +x /usr/local/bin/findomain

# httpx
wget `curl --silent "https://api.github.com/repos/projectdiscovery/httpx/releases/latest" |grep browser_download_url | grep linux_amd64.zip |grep -Po '"browser_download_url": "\K.*?(?=")'` -O /tmp/httpx.zip
unzip /tmp/httpx.zip -d /tmp/
sudo mv /tmp/httpx /usr/local/bin/

# dnsx
wget `curl --silent "https://api.github.com/repos/projectdiscovery/dnsx/releases/latest" |grep browser_download_url | grep linux_amd64.zip |grep -Po '"browser_download_url": "\K.*?(?=")'` -O /tmp/dnsx.zip
unzip /tmp/dnsx.zip -d /tmp/
sudo mv /tmp/dnsx /usr/local/bin/

# subfinder
wget `curl --silent "https://api.github.com/repos/projectdiscovery/subfinder/releases/latest" |grep browser_download_url | grep linux_amd64.zip |grep -Po '"browser_download_url": "\K.*?(?=")'` -O /tmp/subfinder.zip
unzip /tmp/subfinder.zip -d /tmp/
sudo mv /tmp/subfinder /usr/local/bin/

# hakrawler
go install github.com/hakluke/hakrawler@latest
sudo mv ~/go/bin/hakrawler /usr/local/bin/

# waybackurls
go install github.com/tomnomnom/waybackurls@latest
sudo mv ~/go/bin/waybackurls /usr/local/bin/

# gau
go install github.com/lc/gau/v2/cmd/gau@latest
sudo mv ~/go/bin/gau /usr/local/bin/

# anew
go install -v github.com/tomnomnom/anew@latest
sudo mv ~/go/bin/anew /usr/local/bin/

# Sherlock
# docker run theyahya/sherlock user123

# # Z4nzu/hackingtool
# git clone https://github.com/Z4nzu/hackingtool.git ~/GIT-REPOS/CORE/hackingtool
# chmod -R 755 ~/GIT-REPOS/CORE/hackingtool && cd ~/GIT-REPOS/CORE/hackingtool
# sudo pip3 install -r requirement.txt
# bash install.sh

# pspy
sudo wget `curl --silent "https://api.github.com/repos/DominicBreuker/pspy/releases/latest" |grep browser_download_url | grep pspy64 |grep -Po '"browser_download_url": "\K.*?(?=")'` -O /usr/local/bin/pspy64
sudo chmod +x /usr/local/bin/pspy64

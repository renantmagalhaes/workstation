#!/bin/bash

# check cmd function
check_cmd() {
    command -v "$1" 2> /dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS

    sudo apt-get install -y sqlitebrowser aircrack-ng nmap jq

elif check_cmd dnf; then  # FOR RPM SYSTEMS

    sudo dnf install -y sqlitebrowser aircrack-ng nmap jq

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
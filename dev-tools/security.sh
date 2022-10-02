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

# RustScan
brew install rustscan

# Amass
RUN go install -v github.com/OWASP/Amass/v3/...@master && \
mv ~/go/bin/amass /usr/local/bin/

# hakrawler
go install github.com/hakluke/hakrawler@latest && \
sudo mv ~/go/bin/hakrawler /usr/local/bin/

# waybackurls
go install github.com/tomnomnom/waybackurls@latest && \
sudo mv ~/go/bin/waybackurls /usr/local/bin/

# waymore
git clone https://github.com/xnl-h4ck3r/waymore.git ~/GIT-REPOS/CORE/waymore
cd ~/GIT-REPOS/CORE/waymore
sudo python setup.py install
sudo chmod +x ~/GIT-REPOS/CORE/waymore/waymore.py
sudo ln -s -f  $PWD/waymore.py /usr/local/bin/waymore

# gau
go install github.com/lc/gau/v2/cmd/gau@latest && \
sudo mv ~/go/bin/gau /usr/local/bin/

# anew
go install -v github.com/tomnomnom/anew@latest && \
sudo mv ~/go/bin/anew /usr/local/bin/

# Asset finder
go install github.com/tomnomnom/assetfinder@latest && \
sudo mv ~/go/bin/assetfinder /usr/local/bin/

# pspy
sudo wget `curl --silent "https://api.github.com/repos/DominicBreuker/pspy/releases/latest" |grep browser_download_url | grep -m 1 pspy64 |awk {'print $2'} |sed 's/\"//g'` -O /usr/local/bin/pspy64 && sudo chmod +x /usr/local/bin/pspy64

# DNS Recon
git clone https://github.com/darkoperator/dnsrecon.git ~/GIT-REPOS/CORE/dnsrecon && \
cd ~/GIT-REPOS/CORE/dnsrecon && sudo pip3 install -r requirements.txt --no-warn-script-location && \
sudo ln -s -f  $PWD/dnsrecon.py /usr/local/bin/dnsrecon

# Findomain
sudo wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux -O /usr/local/bin/findomain && \
sudo chmod +x /usr/local/bin/findomain

# httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && \
sudo mv ~/go/bin/httpx /usr/local/bin/

# dnsx
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest && \
sudo mv ~/go/bin/dnsx /usr/local/bin/

# subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
sudo mv ~/go/bin/subfinder /usr/local/bin/

# uncover
go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest && \
sudo mv ~/go/bin/uncover /usr/local/bin/
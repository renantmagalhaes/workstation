#!/bin/bash

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

# Add the repository key with either wget or curl
if check_cmd apt-get; then # FOR DEB SYSTEMS

	sudo apt-get install -y sqlitebrowser aircrack-ng nmap jq
	## Set up Go environment variables
	GO_INSTALL_DIR="/usr/local/go"

	## Remove any previous Go installation
	if [ -d "$GO_INSTALL_DIR" ]; then
		echo "Removing previous Go installation from $GO_INSTALL_DIR"
		sudo rm -rf "$GO_INSTALL_DIR"
	fi

	## Fetch the latest version of Go
	echo "Fetching the latest Go version..."
	LATEST_GO_VERSION=$(wget -qO- https://go.dev/VERSION?m=text | head -n 1)

	## Download the latest Go version
	echo "Downloading Go $LATEST_GO_VERSION..."
	wget https://go.dev/dl/$LATEST_GO_VERSION.linux-amd64.tar.gz -O /tmp/go.tar.gz

	## Extract Go to the installation directory
	echo "Extracting Go to $GO_INSTALL_DIR..."
	sudo tar -C /usr/local/ -xzf /tmp/go.tar.gz

	## Clean up the downloaded tar file
	rm /tmp/go.tar.gz

	## Set up Go environment by adding Go to the PATH in /etc/profile.d
	sudo ln -s -f /usr/local/go/bin/go /usr/local/bin/go
	sudo ln -s -f /usr/local/go/bin/gofmt /usr/local/bin/gofmt

elif check_cmd zypper; then # FOR RPM SYSTEMS

	sudo zypper install -y go sqlitebrowser nmap jq SecLists
	brew install aircrack-ng

else
	echo "Not able to identify the system"
fi

# RustScan
brew install rustscan

# Amass
go install -v github.com/OWASP/Amass/v3/...@master &&
	sudo mv ~/go/bin/amass /usr/local/bin/

# CveMap
go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
sudo mv ~/go/bin/cvemap /usr/local/bin/

# hakrawler
go install github.com/hakluke/hakrawler@latest &&
	sudo mv ~/go/bin/hakrawler /usr/local/bin/

# waybackurls
go install github.com/tomnomnom/waybackurls@latest &&
	sudo mv ~/go/bin/waybackurls /usr/local/bin/

# waymore
git clone https://github.com/xnl-h4ck3r/waymore.git ~/GIT-REPOS/CORE/waymore
cd ~/GIT-REPOS/CORE/waymore
sudo python setup.py install
sudo chmod +x ~/GIT-REPOS/CORE/waymore/waymore.py
sudo ln -s -f $PWD/waymore.py /usr/local/bin/waymore

# gau
go install github.com/lc/gau/v2/cmd/gau@latest &&
	sudo mv ~/go/bin/gau /usr/local/bin/

# anew
go install -v github.com/tomnomnom/anew@latest &&
	sudo mv ~/go/bin/anew /usr/local/bin/

# Asset finder
go install github.com/tomnomnom/assetfinder@latest &&
	sudo mv ~/go/bin/assetfinder /usr/local/bin/

# pspy
sudo wget $(curl --silent "https://api.github.com/repos/DominicBreuker/pspy/releases/latest" | grep browser_download_url | grep -m 1 pspy64 | awk {'print $2'} | sed 's/\"//g') -O /usr/local/bin/pspy64 && sudo chmod +x /usr/local/bin/pspy64

# DNS Recon
git clone https://github.com/darkoperator/dnsrecon.git ~/GIT-REPOS/CORE/dnsrecon &&
	cd ~/GIT-REPOS/CORE/dnsrecon && sudo pip3 install -r requirements.txt --no-warn-script-location &&
	sudo ln -s -f $PWD/dnsrecon.py /usr/local/bin/dnsrecon

# Findomain
sudo wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux -O /usr/local/bin/findomain &&
	sudo chmod +x /usr/local/bin/findomain

# gowitness
go install github.com/sensepost/gowitness@latest &&
	sudo mv ~/go/bin/gowitness /usr/local/bin/

# httprobe
go install github.com/tomnomnom/httprobe@latest &&
	sudo mv ~/go/bin/httprobe /usr/local/bin/

# httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest &&
	sudo mv ~/go/bin/httpx /usr/local/bin/

# dnsx
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &&
	sudo mv ~/go/bin/dnsx /usr/local/bin/

# subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &&
	sudo mv ~/go/bin/subfinder /usr/local/bin/

# uncover
go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest &&
	sudo mv ~/go/bin/uncover /usr/local/bin/

####

# Burp
curl -L 'https://portswigger.net/burp/releases/startdownload?product=community&version=2023.9.3&type=Linux' --output /tmp/burp.sh
chmod +x /tmp/burp.sh
sh -c "/tmp/burp.sh"

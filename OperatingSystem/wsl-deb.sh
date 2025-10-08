#!/bin/sh
#
#
#?Site        :https://insecure.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#
# RTM

# Verifications
if [ “$(id -u)” = “0” ]; then
	echo “Dont run this script as root” 2>&1
	exit 1
fi

# Check if the file /etc/wsl.conf exists and systemd is configured
if [ ! -f /etc/wsl.conf ]; then
	sudo bash -c 'cat << EOF > /etc/wsl.conf
# Set a command to run when a new WSL instance launches.
[boot]
systemd=true

# Set whether WSL supports interop process like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
appendWindowsPath=true

# Automatically mount Windows drive when the distribution is launched
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives wont be mounted automatically, but need to be mounted manually or with fstab.
enabled = true
EOF'
	echo "/etc/wsl.conf file created successfully."
	echo "Shutting down WSL"
	wsl.exe --shutdown
else
	echo "systemd configured. Proceeding."
fi

# refresh repos
sudo apt-get update

# Dotfiles syslink
ln -s -f $PWD/dotfiles/ ~/.dotfiles

# Set tz
sudo apt install -y ntpdate
sudo ntpdate pool.ntp.org

# upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install zsh fonts-powerline vim wget tmux curl net-tools iproute2 git fonts-hack-ttf apt-transport-https htop meld tree nload pwgen sysstat xclip unrar-free unzip python3 python3-pip net-tools ncdu whois flatpak xournal evince jq dnsutils nala sassc gawk telnet bc neofetch python3-venv sqlite3 pipx cifs-utils python3-requests ffmpeg nmon

# Latest Go
bash ./scripts/latest-go.sh

# Latest Node
bash ./scripts/latest-node.sh

# Flatpack
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Utils
# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# SCRIPTS
## Install Nix
bash ./scripts/nix-install.sh

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f "/etc/profile.d/nix.sh" ]; then
	. "/etc/profile.d/nix.sh"
else
	echo "Nix environment script not found."
	exit 1
fi

## Nix packages
bash ./OperatingSystem/nix-packages.sh

## Brew
bash ./scripts/brew.sh

## Fonts
bash ./scripts/fonts.sh

## VIM
bash ./scripts/vim.sh

## TMUX
bash ./scripts/tmux.sh

## ZSH
bash ./scripts/zsh.sh

## Neofetch
bash ./scripts/neofetch.sh

## GIT
bash ./utils/git-config/git-config.sh

# Install pip packages
pipx install virtualenv
pipx install virtualenvwrapper
pipx install pylint
pipx install bpytop

# WSL config
sudo bash -c 'cat << EOF > /mnt/c/Users/renan/.wslconfig
[wsl2]
memory=6GB # Limits VM memory in WSL 2
swap=0
#processors=4 # Makes the WSL 2 VM use 4 virtual processors
localhostForwarding=true # Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port.
EOF'

# Fix WSL2 for debian(temporary solution)
sudo bash -c 'cat << EOF > /usr/lib/binfmt.d/WSLInterop.conf
:WSLInterop:M::MZ::/init:PF
EOF'

# Fix ping
sudo setcap 'cap_net_raw+p' /bin/ping

# Set WSL default distro
wsl.exe --setdefault Debian

# Powertoys windows modifier
pip3.exe install keyboard

# Docker Latest
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl restart docker
sudo usermod -aG docker $USER

# ADB setup
#sudo ln -s -f /mnt/c/Program\ Files/Genymobile/Genymotion/tools/adb.exe /usr/local/bin/adb

# fd - ignore NFS
bash ./scripts/fd-ignore.sh

# Make sure all package are installed
sudo apt-get -f install -y

# Make tmux default shell
sudo usermod --shell /usr/bin/tmux $USER

# Change to zsh
zsh

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         insecure.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

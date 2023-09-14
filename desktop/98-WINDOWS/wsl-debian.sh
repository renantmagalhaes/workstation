#!/bin/sh
#
#
#?Site        :https://rtm.codes
#?Author      :Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
#?                                     <https://github.com/renantmagalhaes>
#
# RTM

# Verifications 
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi

# refresh repos
sudo apt-get update

# Set tz
sudo apt install -y ntpdate
sudo ntpdate pool.ntp.org

# upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install zsh fonts-powerline vim wget tmux curl net-tools iproute2 git fonts-hack-ttf apt-transport-https htop meld tree nload pwgen sysstat xclip unrar-free unzip python3 python3-pip net-tools ncdu whois flatpak snapd xournal evince jq bpytop virtualenv virtualenvwrapper pylint dnsutils nala

# Flatpack
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Brew
bash ../source/any/brew.sh

#Utils
## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python


# Create git-folder 
mkdir -p ~/GIT-REPOS/CORE

# Install LSD
curl https://sh.rustup.rs -sSf | sh
~/.cargo/bin/cargo install lsd

# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls


# Enable Systemd
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

# Install Fonts
# Fonts
bash ../source/any/fonts.sh

# New VIM
bash ../source/any/vim.sh

# Docker
sudo apt-get -y install docker.io docker-compose
sudo systemctl enable docker
sudo systemctl restart docker
sudo usermod -aG docker $USER

# Make sure all package are installed
sudo apt-get -f install -y

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

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
sudo apt-get -y install zsh fonts-powerline vim tmux curl net-tools iproute2 git fonts-hack-ttf apt-transport-https htop meld tree nload pwgen sysstat fzf neofetch xclip unrar unzip python3 python3-pip net-tools ncdu whois flatpak snapd xournal evince jq
sudo apt-get -f install -y


# Flatpack
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Brew
bash ../source/any/brew.sh

#Utils

## LSD
wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd-musl_0.23.1_amd64.deb -O /tmp/lsd_amd64.deb
sudo dpkg -i /tmp/lsd_amd64.deb

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python


# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade
sudo apt-get -f install -y

# Create git-folder 
mkdir -p ~/GIT-REPOS/CORE


# Colorls
sudo apt install -y ruby-dev
sudo gem install colorls
sudo apt-get -f install -y

# Enable Systemd
sudo bash -c 'cat << EOF > /etc/wsl.conf
[boot]
systemd=true
EOF'

# WSL config
sudo bash -c 'cat << EOF > /mnt/c/Users/renan/.wslconfig
[wsl2]
memory=6GB # Limits VM memory in WSL 2
swap=0
#processors=4 # Makes the WSL 2 VM use 4 virtual processors
localhostForwarding=true # Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port.
EOF'


# Install Fonts
# Fonts
bash ../source/any/fonts.sh

# New VIM
bash ../source/any/vim.sh

# Make sure all package are installed
sudo apt-get -f install -y

# RTM
# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
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

# refresh repos and upgrade system
sudo zypper dup

# Set tz
sudo zypper install -y ntp
sudo ntpdate pool.ntp.org


# Install the packages from repo
sudo zypper install -y zsh vim tmux curl net-tools iproute2 git htop meld tree nload pwgen sysstat xclip unrar unzip python3 python3-pip net-tools ncdu whois flatpak neofetch evince jq firefox

# Install SNAP
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install -y snapd


# Brew
bash ../source/any/brew.sh

#Utils

# Colorls
sudo zypper install -y ruby ruby-devel ruby nodejs git gcc make libopenssl-devel sqlite3-devel
sudo gem install colorls

# Install LSD
curl https://sh.rustup.rs -sSf | sh
~/.cargo/bin/cargo install lsd

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

# Install pip packages
sudo pip3 install virtualenv virtualenvwrapper pylint
sudo pip3 install bpytop --upgrade


# Create git-folder 
mkdir -p ~/GIT-REPOS/CORE

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



# RTM
# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"
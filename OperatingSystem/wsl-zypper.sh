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

# Check if the file /etc/wsl.conf exists and systemd is configured
if [ ! -f /etc/wsl.conf ]; then
	# # Enable Systemd
	sudo zypper -n in --auto-agree-with-licenses -t pattern wsl_systemd
	sudo zypper in -t pattern wsl_gui
	wsl.exe --shutdown
else
	echo "systemd configured. Proceeding."
fi

# refresh repos and upgrade system
sudo zypper ref && sudo zypper dup

# Dotfiles syslink
ln -s -f $PWD/dotfiles/ ~/.dotfiles

# Set tz
sudo zypper install -y ntp
sudo ntpdate pool.ntp.org

# Install the packages from repo
sudo zypper install -y zsh vim curl net-tools net-tools-deprecated iproute2 git htop meld tree nload pwgen sysstat xclip unrar unzip python3 python3-pip net-tools ncdu whois flatpak neofetch evince jq firefox bind-utils gcc-c++ rsync sassc gawk bc cron golang npm libcap-progs sqlite3 python312-pipx cifs-utils ffmpeg python3-requests nmon

# Install yarn
sudo npm install --global yarn

# Patterns
sudo zypper -n install --type pattern devel_basis

# # Install SNAP
# wsl_thumbleweed_check=$(env | grep WSL | grep -ioh "openSUSE-Tumbleweed" | awk '{print tolower($0)}')
# wsl_leap_check=$(env | grep WSL | grep -ioh "openSUSE-Leap" | awk '{print tolower($0)}')
# if [[ $wsl_leap_check == "opensuse-leap" ]]; then
# 	sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_$(cat /etc/os-release | grep VERSION_ID | egrep -Eoh '[0-9]{1,3}.[0-9]{1,3}') snappy
# elif [[ $wsl_thumbleweed_check == "opensuse-tumbleweed" ]]; then
# 	sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
# fi

# sudo zypper --gpg-auto-import-keys refresh
# sudo zypper dup --from snappy
# sudo zypper install -y snapd

# Flatpack
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# SCRIPTS
# Disable SELINUX
bash ./scripts/selinux.sh

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
### Temporary install Tmux via brew
/home/linuxbrew/.linuxbrew/bin/brew install tmux
sudo ln -s -f /home/linuxbrew/.linuxbrew/bin/tmux /usr/bin/tmux
bash ./scripts/tmux.sh

## ZSH
bash ./scripts/zsh.sh

## Neofetch
bash ./scripts/neofetch.sh

## GIT
bash ./utils/git-config/git-config.sh

# Temporary install Tmux via brew
/home/linuxbrew/.linuxbrew/bin/brew install tmux
sudo ln -s -f /home/linuxbrew/.linuxbrew/bin/tmux /usr/bin/tmux

#Utils

## Fix python default path
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo ln -s /usr/bin/pip3 /usr/bin/pip

# Install pip packages
pipx install wheel
pipx install virtualenv virtualenvwrapper pylint
pipx install bpytop

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fix ping
sudo setcap 'cap_net_raw+p' /bin/ping

# Fix systemd init
#sudo ln -s /usr/lib/systemd/systemd /sbin/init

# WSL config
sudo bash -c 'cat << EOF > /mnt/c/Users/renan/.wslconfig
[wsl2]
memory=6GB # Limits VM memory in WSL 2
swap=0
#processors=4 # Makes the WSL 2 VM use 4 virtual processors
localhostForwarding=true # Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port.
EOF'

# Set WSL default distro
wsl.exe --setdefault openSUSE-Tumbleweed

# Docker
sudo zypper install -y docker docker-compose docker-compose-switch
sudo systemctl enable docker
sudo usermod -G docker -a $USER
sudo systemctl restart docker

# fd - ignore NFS
bash ./scripts/fd-ignore.sh


# Make tmux default shell
sudo usermod --shell /usr/bin/tmux $USER

# Change to ZSH
zsh

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.codes             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

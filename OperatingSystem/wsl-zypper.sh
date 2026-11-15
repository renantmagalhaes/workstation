#!/bin/sh
#
#
#?Site        :https://rtm.cc
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

# Configure parallel downloads (20 concurrent connections for high-speed link)
sudo mkdir -p /etc/zypp/zypp.conf.d
sudo tee /etc/zypp/zypp.conf.d/downloads.conf >/dev/null <<'EOF'
[main]
download.max_concurrent_connections = 20
EOF

# Switch to official Fastly CDN repositories & disable source repos
sudo zypper in -y openSUSE-repos-Tumbleweed
sudo zypper mr -d download.opensuse.org-oss 2>/dev/null || true
sudo zypper mr -d 'Main Repository (Sources)' 2>/dev/null || true

# refresh repos and upgrade system
sudo zypper ref && sudo zypper dup -y

# Dotfiles syslink
DOTFILES_DIR="$PWD/dotfiles"
if [[ ! -L "$HOME/.dotfiles" ]] || [[ "$(readlink "$HOME/.dotfiles")" != "$DOTFILES_DIR" ]]; then
  echo "🔗 Creating ~/.dotfiles symlink..."
  ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Set tz
sudo zypper install -y ntp
sudo ntpdate pool.ntp.org

# Install the packages from repo
sudo zypper install -y zsh vim curl net-tools net-tools-deprecated iproute2 git htop meld tree nload pwgen sysstat xclip unrar unzip python3 python3-pip net-tools ncdu whois flatpak neofetch evince jq firefox bind-utils gcc-c++ rsync sassc gawk bc cron golang npm libcap-progs sqlite3 python312-pipx cifs-utils ffmpeg python3-requests nmon zoxide btop

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

## Btop
mkdir -p ~/.config/btop
ln -s -f "$PWD/dotfiles/btop/btop.conf" ~/.config/btop/btop.conf

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

# Create git-folder
mkdir -p ~/GIT-REPOS/CORE

# Fix ping
sudo setcap 'cap_net_raw+p' /bin/ping

# Fix systemd init
#sudo ln -s /usr/lib/systemd/systemd /sbin/init

# WSL config
write_wslconfig() {
  _target_dir="$1"
  [ -d "$_target_dir" ] || return 0
  echo "Configuring WSL (.wslconfig) for: $_target_dir"
  sudo tee "$_target_dir/.wslconfig" >/dev/null <<'EOF'
[wsl2]
memory=12GB # Limits VM memory in WSL 2
swap=0
#processors=4 # Makes the WSL 2 VM use 4 virtual processors
#localhostForwarding=true # Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port.
networkingMode=mirrored
EOF
}

WIN_USER="${WIN_USER:-${WINDOWS_USER:-}}"
CONFIGURED_WSL=false
DETECTED_PROFILE=""

if [ -n "$WIN_USER" ]; then
  if [ -d "/mnt/c/Users/$WIN_USER" ]; then
    write_wslconfig "/mnt/c/Users/$WIN_USER"
    CONFIGURED_WSL=true
  elif [ -d "$WIN_USER" ]; then
    write_wslconfig "$WIN_USER"
    CONFIGURED_WSL=true
  else
    echo "Warning: Windows user directory for '$WIN_USER' not found."
  fi
else
  # 1. Try detecting active Windows user profile via cmd.exe and wslpath
  CMD_EXE=$(command -v cmd.exe 2>/dev/null || echo "/mnt/c/Windows/System32/cmd.exe")
  if [ -x "$CMD_EXE" ]; then
    WIN_PROFILE_RAW=$("$CMD_EXE" /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r\n')
    if [ -n "$WIN_PROFILE_RAW" ] && command -v wslpath >/dev/null 2>&1; then
      DETECTED_PROFILE=$(wslpath "$WIN_PROFILE_RAW" 2>/dev/null)
      if [ -d "$DETECTED_PROFILE" ]; then
        write_wslconfig "$DETECTED_PROFILE"
        CONFIGURED_WSL=true
      fi
    fi
    # Fallback to %USERNAME% if wslpath was unavailable or profile not resolved
    if [ "$CONFIGURED_WSL" = false ]; then
      WIN_NAME_RAW=$("$CMD_EXE" /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n ')
      if [ -n "$WIN_NAME_RAW" ] && [ -d "/mnt/c/Users/$WIN_NAME_RAW" ]; then
        DETECTED_PROFILE="/mnt/c/Users/$WIN_NAME_RAW"
        write_wslconfig "$DETECTED_PROFILE"
        CONFIGURED_WSL=true
      fi
    fi
  fi

  # 2. Automatically detect Windows user(s) under /mnt/c/Users
  if [ -d "/mnt/c/Users" ]; then
    for udir in /mnt/c/Users/*; do
      [ -d "$udir" ] || continue
      ubase=$(basename "$udir")
      case "$ubase" in
      Public | Default | "Default User" | "All Users" | defaultuser* | desktop.ini)
        continue
        ;;
      *)
        # Avoid re-writing if already configured by active profile check above
        if [ "$CONFIGURED_WSL" = true ] && [ "$udir" = "$DETECTED_PROFILE" ]; then
          continue
        fi
        write_wslconfig "$udir"
        CONFIGURED_WSL=true
        ;;
      esac
    done
  fi
fi

if [ "$CONFIGURED_WSL" = false ]; then
  echo "Warning: Could not detect Windows user profile directory. Skipping .wslconfig creation."
fi

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

# Set locale
sudo localectl set-locale LANG=en_US.UTF-8

# Change to ZSH
zsh

# RTM
#clear
echo "#################################"
echo "#                               #"
echo "#         rtm.cc             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

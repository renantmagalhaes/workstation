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

# Configure parallel downloads for APT
sudo tee /etc/apt/apt.conf.d/99parallel >/dev/null <<'EOF'
Acquire::Queue-Mode "host";
Acquire::http::Pipeline-Depth "5";
EOF

# Dotfiles syslink
DOTFILES_DIR="$PWD/dotfiles"
if [[ ! -L "$HOME/.dotfiles" ]] || [[ "$(readlink "$HOME/.dotfiles")" != "$DOTFILES_DIR" ]]; then
  echo "🔗 Creating ~/.dotfiles symlink..."
  ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Set tz
sudo apt install -y ntpsec-ntpdate
sudo ntpsec-ntpdate pool.ntp.org

# upgrade
sudo apt-get update && sudo apt-get -y upgrade

# Install the packages from repo
sudo apt-get -y install zsh fonts-powerline vim wget tmux curl net-tools iproute2 git fonts-hack-ttf apt-transport-https htop meld tree nload pwgen sysstat xclip unrar-free unzip python3 python3-pip net-tools ncdu whois flatpak xournal evince jq dnsutils nala sassc gawk telnet bc python3-venv sqlite3 pipx cifs-utils python3-requests ffmpeg nmon nmap jp2a zip imagemagick gcc make ruby-dev python-is-python3 openvpn btop

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

## Fastfetch
ln -s -f "$PWD/dotfiles/fastfetch/" ~/.config/

## GIT
bash ./utils/git-config/git-config.sh

# Install pip packages
pipx install virtualenv
pipx install virtualenvwrapper
pipx install pylint
pipx install btop
pipx ensurepath

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
        Public|Default|"Default User"|"All Users"|defaultuser*|desktop.ini)
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
echo "#         rtm.cc             #"
echo "#     Please reboot your pc     #"
echo "#                               #"
echo "#################################"

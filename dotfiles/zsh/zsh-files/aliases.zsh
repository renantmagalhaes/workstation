# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

#RTM
macos_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')
linux_check=$(uname -a | awk '{print $1}' | awk '{print tolower($0)}')

# alias with preview files on
alias pf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
# crontab editor
export VISUAL=vim

#Aliases
gnome_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "GNOME" | awk '{print tolower($0)}')
kde_check=$(env | grep XDG_CURRENT_DESKTOP | grep -ioh "KDE" | awk '{print tolower($0)}')
bspwm_check=$(env | grep DESKTOP_SESSION | grep -ioh "bspwm" | awk '{print tolower($0)}')
wsl_debian_check=$(env | grep WSL | grep -ioh "debian" | awk '{print tolower($0)}')
wsl_thumbleweed_check=$(env | grep WSL | grep -ioh "openSUSE-Tumbleweed" | awk '{print tolower($0)}')
wsl_leap_check=$(env | grep WSL | grep -ioh "openSUSE-Leap" | awk '{print tolower($0)}')

if check_cmd wsl.exe; then
    alias pdf="evince"
    alias wsl-update="wsl.exe --update"
    alias wsl-shutdown="wsl.exe --shutdown"
    alias wsl-delete="wsl.exe --unregister"
    alias wsl-rm-zone-file-recursive="find . -type f -name '*Zone.Identifier*' -exec rm -rf {} +"
    alias wsl-rm-zone-file="find . -maxdepth 1 -type f -name '*Zone.Identifier*' -exec rm -rf {} +"
    alias wsl-list="wsl.exe --list"
    if check_cmd files.exe; then
        # current_path=$(pwd)
        # FilesAppPath=$(echo $current_path | sed -e 's|^/|\\\\wsl.localhost\\openSUSE-Tumbleweed\\|' -e 's|/|\\|g')
        # alias folder="files.exe '$FilesAppPath'"
        alias folder="explorer.exe"
    else
        alias folder="explorer.exe"
    fi
    if [[ $wsl_debian_check == "debian" ]]; then
        alias update-all="sudo apt update && sudo apt upgrade -y && brew update && brew upgrade && sudo flatpak update -y && nix-env --upgrade"
        alias sudo="sudo "
        alias apt="nala"
    elif [[ $wsl_thumbleweed_check == "opensuse-tumbleweed" ]]; then
        alias update-all="sudo zypper ref && sudo zypper dup && brew update && brew upgrade && sudo flatpak update -y && nix-env --upgrade"
    elif [[ $wsl_leap_check == "opensuse-leap" ]]; then
        alias update-all="sudo zypper ref && sudo zypper up && brew update && brew upgrade && sudo flatpak update -y && nix-env --upgrade"
    fi
elif check_cmd apt-get; then # FOR DEB SYSTEMS
    alias update-all="sudo apt update && sudo apt upgrade -y && brew update && brew upgrade && sudo flatpak update -y && nix-env --upgrade"
    alias sudo="sudo "
    alias apt="nala"
    if [[ $gnome_check == "gnome" ]]; then
        alias folder="nautilus"
        alias pdf="evince"
    elif [[ $bspwm_check == "bspwm" ]]; then
        alias folder="nautilus"
        alias pdf="evince"
    elif [[ $kde_check == "kde" ]]; then
        alias folder="dolphin"
        alias pdf="evince"
    fi

elif check_cmd zypper; then # FOR ZYPPER TW SYSTEMS
    alias update-all="sudo zypper ref && sudo zypper dup && brew update && brew upgrade && sudo flatpak update -y && nix-env --upgrade"
    if [[ $gnome_check == "gnome" ]]; then
        alias folder="nautilus"
        alias pdf="evince"
    elif [[ $bspwm_check == "bspwm" ]]; then
        alias folder="nautilus"
        alias pdf="evince"
    fi
fi

# SYSTEM ALIASES
if [[ $macos_check == "darwin" ]]; then
    alias killtmux="killall tmux"
    alias python="python3"
    alias killvivaldi="killall Vivaldi"

elif [[ $linux_check == "linux" ]]; then
    alias killtmux="pidof tmux |xargs kill -9"
    alias python="python3"
    alias killedge="pidof msedge |xargs kill -9"
    alias killgnome="killall -HUP gnome-shell"
    # alias bluetooth-restart="sudo rfkill block bluetooth && sudo rfkill unblock bluetooth && sudo systemctl restart bluetooth"
    alias bluetooth-restart="sudo systemctl stop bluetooth.service && sudo rm -rf /var/lib/bluetooth/* && sudo systemctl start bluetooth.service"
    alias vga-info="lspci -nnk |grep -A3 VGA"
    alias latte-restart="pidof latte-dock |xargs kill -9 && latte-dock &"
    alias flatpak-home-permission="sudo flatpak override --filesystem=home:ro"
    # LINUX UTILS
    alias mouse-battery='upower --dump |grep -A 5 mouse | egrep -oh '"'"'[0-9]*%'"'"''
    alias ascii-image='jp2a --output=ascii.txt --colors $1'
    alias pdf-signature='xournal'
    alias nordvpn-c='sudo nordvpn connect && sudo nordvpn set killswitch on && sudo nordvpn set autoconnect on && sudo nordvpn set lan-discovery on'
    alias nordvpn-d='sudo nordvpn set autoconnect off && sudo nordvpn set killswitch off && sudo nordvpn disconnect'
    alias wireguard-c='sudo wg-quick up wireguard'
    alias wireguard-d='sudo wg-quick down wireguard'

else
    echo "error on SO check"
fi

alias cp='cp -iv'
alias rm='rm -ir'
alias mv='mv -iv'
alias ln='ln -sriv'
alias xclip='xclip -selection c'
alias files='fzf'
command -v vim >/dev/null && alias vi='vim'

#eval $(thefuck --alias)

### Colorize commands
#alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

### LS & TREE
alias ll='ls -la'
alias la='ls -A'
alias l='ls -F'
alias ls='lsd'

### SSH-KEYGEN ###
alias ssh-keygen-4096='ssh-keygen -t rsa -b 4096'
alias ssh-keygen-ed25519='ssh-keygen -t ed25519'

# VIM
alias vi='nvim'
alias visearch='nvim $(fzf --preview="bat --style=plain --color=always {}")'

### UTILS ###
alias disk-manager='ncdu'
alias git-sync='git add -A && git commit -m sync && git push'
alias webserver-python='python -m http.server 8888'
alias vim-clean-swap='rm -rf /home/rtm/.local/state/nvim/swap/*'
alias nvim-clean-swap='rm -rf /home/rtm/.local/state/nvim/swap/*'
alias python-activate-venv='python -m venv venv && source ./venv/bin/activate'
alias systemctl-list-services='sudo systemctl list-unit-files'
alias systemctl-running-services='sudo systemctl |grep running'

### NIX ###
alias nix-install='nix-env -i'
alias nix-remove='nix-env --uninstall'
alias nix-search='echo "Go to https://search.nixos.org/packages"'

### System ###
alias pip='pipx'
alias pip3='python -m pip'
alias vinotes='vi ~/notes.md'
alias lg='lazygit'
alias killvi='pidof nvim |xargs kill -9'

#Hex color get
for name in hex-color color-hex; do
  alias $name='xcolor'
done


### Zypper UTILS
alias zypper-reinstall='sudo zypper install --force'

### chmod alias
alias 755d="find . -type d -exec chmod 755 {} \;"
alias 644f="find . -type f -exec chmod 644 {} \;"

### Security Tools ###
alias openssl-check='docker run -it --rm drwetter/testssl.sh'
alias sherlock='docker run -i theyahya/sherlock'
alias legion='docker run -it carlospolop/legion:latest sh -c "/legion/legion.py"'
alias waymore='python3 ~/GIT-REPOS/CORE/waymore/waymore.py'

### ControlD ###
alias ControlD-disable-ttl='python3 ~/.dotfiles/os/controlD/disable_ttl.py'
alias ControlD-allow-website='python3 ~/.dotfiles/os/controlD/allowWebsite.py'

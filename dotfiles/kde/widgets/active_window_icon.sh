#!/bin/bash

# Get focused window ID
win_id=$(xdotool getwindowfocus 2>/dev/null)

# Get WM_CLASS (second string is usually the app name)
app=$(xprop -id "$win_id" WM_CLASS 2>/dev/null | awk -F\" '{print $4}' | tr '[:upper:]' '[:lower:]')

# Don't show anything for plasmashell
if [[ "$app" == "plasmashell" ]]; then
	exit 0
fi

# Default fallback
icon="" # generic window icon

case "$app" in
# Browsers
firefox | brave | google-chrome | chromium | vivaldi | vivaldi-stable | epiphany | midori | falkon)
	icon=""
	;;

# Code editors & IDEs
code | vscode | code-oss | visual-studio-code)
	icon=""
	;;
clion)
	icon=""
	;;
datagrip)
	icon=""
	;;
gdevelop)
	icon=""
	;;
intellij-idea)
	icon=""
	;;
phpstorm)
	icon=""
	;;
pycharm)
	icon=""
	;;
rider)
	icon=""
	;;
unityhub)
	icon=""
	;;
webstorm)
	icon=""
	;;

# Terminal emulators
gnome-terminal | konsole | xfce4-terminal | xterm | urxvt | kitty | alacritty | tilix | guake | terminator | lxterminal)
	icon=""
	;;

# File managers
nautilus | dolphin | thunar | pcmanfm | nemo | caja)
	icon=""
	;;

# Communication
telegram | telegramdesktop)
	icon=""
	;;
discord)
	icon=""
	;;
slack)
	icon=""
	;;
teams)
	icon=""
	;;
signal | element | gajim)
	icon=""
	;;
caprine)
	icon=""
	;;

# Multimedia
spotify)
	icon=""
	;;
vlc)
	icon="嗢"
	;;
gimp | krita)
	icon=""
	;;
eog | gthumb)
	icon=""
	;;

# Notes & email
thunderbird | protonmail)
	icon=""
	;;
obsidian)
	icon=""
	;;
notion)
	icon=""
	;;

# System tools
htop | stacer)
	icon=""
	;;
systemmonitor | gkrellm)
	icon=""
	;;
gparted | disks)
	icon=""
	;;
bleachbit)
	icon=""
	;;
timeshift | deja-dup | backintime)
	icon=""
	;;
baobab)
	icon=""
	;;
gnome-calculator | kcalc)
	icon=""
	;;
plasma-discover)
	icon=""
	;;

# Security & utilities
bitwarden | keepassxc | veracrypt | authy)
	icon=""
	;;
docker)
	icon=""
	;;
virtualbox | virt-manager | qemu)
	icon=""
	;;
postman | insomnia)
	icon=""
	;;
burpsuite)
	icon=""
	;;
nmap)
	icon=""
	;;
gns3)
	icon=""
	;;

# Other
akregator)
	icon=""
	;;
github-desktop)
	icon=""
	;;
kate | flatseal | devdocs)
	icon=""
	;;
zoom)
	icon=""
	;;
esac

echo "$icon  $app"

#!/usr/bin/env bash

# Get all WM_CLASS entries from the active window
classes=$(xprop -id "$(xdotool getactivewindow 2>/dev/null)" WM_CLASS 2>/dev/null | awk -F'"' '{for (i=2;i<=NF;i+=2) printf "%s ", $i}')
classes=${classes,,}  # lowercase for uniform matching

# Helper for partial, case-insensitive matching
match() { [[ "$classes" == *"$1"* ]]; }

# ───────────────────────────────────────────────
# WebApps / Chromium-based Apps (priority first)
# ───────────────────────────────────────────────
if match "crx_hnpfjngllnobngcgfapefoaidbinmjnm"; then icon=""   # WhatsApp
elif match "crx_aohghmighlieiainnegkcijnfilokake"; then icon=""   # Google Docs
elif match "crx_apdfllckaahabafndbhieahigkjlhalf"; then icon=""   # PDF Viewer
elif match "crx_fahmaaghhglfmonjliepjlchgpgfmobi"; then icon=""   # Google Keep
elif match "crx_coobgpohoikkiipiblmjeljniedjpjpf"; then icon=""   # Chrome Extension Host
elif match "crx_ejfnjlabfjijegcfjljfdkpdiogikbco"; then icon="󰊫"   # Notion
elif match "crx_pjkljhegncpnkpknbcohdijeoejaedia"; then icon=""   # Gmail
elif match "crx_cjpalhdlnbpafiamejdnhcphjbkeiagm"; then icon=""   # uBlock Origin
elif match "crx_bikioccmkafdpakkkcpdbppfkghcmihk"; then icon="󰋋"   # Google Calendar
elif match "crx_mjcnijlhddpbdemagnpefmlkjdagkogk"; then icon="󰗃"   # YouTube Music

# ───────────────────────────────────────────────
# Browsers
# ───────────────────────────────────────────────
elif match "firefox"; then icon=""
elif match "vivaldi"; then icon="󰇩"
elif match "chrome"; then icon=""
elif match "chromium"; then icon=""
elif match "brave"; then icon=""
elif match "edge"; then icon="󰇩"
elif match "tor"; then icon=""
elif match "epiphany" || match "gnome-web"; then icon=""

# ───────────────────────────────────────────────
# Terminals
# ───────────────────────────────────────────────
elif match "kitty"; then icon=""
elif match "alacritty"; then icon=""
elif match "konsole"; then icon=""
elif match "gnome-terminal"; then icon=""
elif match "xfce4-terminal"; then icon=""
elif match "tilix"; then icon=""
elif match "wezterm"; then icon=""
elif match "xterm"; then icon=""
elif match "guake"; then icon=""
elif match "yakuake"; then icon=""

# ───────────────────────────────────────────────
# Editors / IDEs
# ───────────────────────────────────────────────
elif match "code"; then icon="󰨞"
elif match "cursor"; then icon="󰨞"
elif match "sublime"; then icon=""
elif match "atom"; then icon=""
elif match "notepadqq"; then icon=""
elif match "intellij"; then icon=""
elif match "pycharm"; then icon=""
elif match "webstorm"; then icon=""
elif match "clion"; then icon=""
elif match "android-studio"; then icon=""
elif match "qtcreator"; then icon="󰯲"
elif match "gedit"; then icon=""
elif match "kate"; then icon="󰦒"
elif match "vim" || match "nvim" || match "neovim"; then icon=""

# ───────────────────────────────────────────────
# File Managers
# ───────────────────────────────────────────────
elif match "nautilus" || match "dolphin" || match "nemo" || match "thunar" || match "pcmanfm"; then icon=""
elif match "doublecmd"; then icon="󰉋"

# ───────────────────────────────────────────────
# Chat / Communication
# ───────────────────────────────────────────────
elif match "discord"; then icon="󰙯"
elif match "slack"; then icon="󰒱"
elif match "telegram"; then icon=""
elif match "signal"; then icon="󰍪"
elif match "skype"; then icon=""
elif match "teams"; then icon="󰊻"
elif match "zoom"; then icon=""
elif match "element"; then icon="󰫢"
elif match "hexchat"; then icon="󰬴"

# ───────────────────────────────────────────────
# Media Players
# ───────────────────────────────────────────────
elif match "spotify"; then icon="󰓇"
elif match "vlc"; then icon="󰕼"
elif match "mpv"; then icon="󰍬"
elif match "rhythmbox"; then icon="󰎆"
elif match "audacious"; then icon=""
elif match "clementine"; then icon="󰋋"

# ───────────────────────────────────────────────
# Office / Productivity
# ───────────────────────────────────────────────
elif match "libreoffice"; then icon="󰈬"
elif match "writer"; then icon="󰈬"
elif match "calc"; then icon="󰪾"
elif match "impress"; then icon="󰐫"
elif match "evince" || match "okular" || match "zathura"; then icon=""
elif match "gimp"; then icon=""
elif match "inkscape"; then icon=""
elif match "krita"; then icon=""
elif match "drawio"; then icon="󰕯"
elif match "notion"; then icon="󰊫"
elif match "obsidian"; then icon="󱓧"

# ───────────────────────────────────────────────
# System Tools / Settings
# ───────────────────────────────────────────────
elif match "gnome-control-center" || match "systemsettings"; then icon=""
elif match "gnome-disks"; then icon=""
elif match "htop" || match "btop"; then icon="󰍛"
elif match "virt-manager"; then icon=""
elif match "virtualbox"; then icon="󰆧"
elif match "vmware"; then icon="󰆧"
elif match "qemu" || match "quickemu"; then icon=""
elif match "pavucontrol"; then icon="󰕾"
elif match "blueman"; then icon="󰂯"
elif match "nm-connection-editor" || match "network"; then icon="󰈀"
elif match "gnome-system-monitor"; then icon=""
elif match "timeshift"; then icon="󰋻"
elif match "synology"; then icon="󰣇"
elif match "nextcloud"; then icon="󰅩"

# ───────────────────────────────────────────────
# Browsing / Misc Tools
# ───────────────────────────────────────────────
elif match "steam"; then icon="󰓓"
elif match "lutris"; then icon="󰖺"
elif match "heroic"; then icon="󰖺"
elif match "bottles"; then icon="󰡶"
elif match "obs"; then icon="󰨜"
elif match "filezilla"; then icon="󰏇"
elif match "transmission" || match "deluge"; then icon=""
elif match "qbittorrent"; then icon=""
elif match "gparted"; then icon=""
elif match "ark"; then icon=""
elif match "baobab"; then icon="󰋊"
elif match "xviewer" || match "eog" || match "gwenview"; then icon="󰈥"
elif match "flameshot" || match "spectacle"; then icon=""
elif match "gnome-calendar"; then icon=""
elif match "keepassxc"; then icon=""
elif match "bitwarden"; then icon=""
elif match "burp"; then icon=""
elif match "wireshark"; then icon="󰲡"
elif match "zenmap"; then icon="󰲡"
elif match "postman"; then icon="󰘬"
elif match "insomnia"; then icon="󰘬"
elif match "docker" || match "lazydocker"; then icon="󰡨"
elif match "virt-viewer"; then icon=""
elif match "remmina"; then icon="󰢹"

# ───────────────────────────────────────────────
# Default
# ───────────────────────────────────────────────
else icon=""
fi

echo "$icon"

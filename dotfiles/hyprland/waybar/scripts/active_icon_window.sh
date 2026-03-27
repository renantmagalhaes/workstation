#!/usr/bin/env bash
# Hyprland active window -> Nerd Font icon
# Dependencies: hyprctl, jq

# Fetch active window JSON
json="$(hyprctl -j activewindow 2>/dev/null)" || json=""
if [[ -z "$json" || "$json" == "null" ]]; then
	echo ""
	exit 0
fi

# Pull multiple identifiers, then lowercase for case-insensitive matching
class=$(jq -r '.class // empty' <<<"$json")
initial_class=$(jq -r '.initialClass // empty' <<<"$json")
title=$(jq -r '.title // empty' <<<"$json")
initial_title=$(jq -r '.initialTitle // empty' <<<"$json")

# Build a single search blob
classes="$class $initial_class $title $initial_title"
classes="${classes,,}" # lowercase

# Helper for partial match
match() { [[ "$classes" == *"$1"* ]]; }

icon="" # default

# ───────────────────────────────────────────────
# WebApps / Chromium-based Apps (priority first)
# Keep your CRX IDs, they often show up as instance or in titles under XWayland
# ───────────────────────────────────────────────
if match "whatsapp web" || match "whatsapp"; then
	icon=""
elif match "thunderbird"; then
	icon=""
elif match "gmail"; then
	icon=""
elif match "google keep" || match "keep.google"; then
	icon="󱞎"
elif match "google docs" || match "docs.google"; then
	icon="󰈙"
elif match "google sheets" || match "sheets.google"; then
	icon="󰈛"
elif match "google slides" || match "slides.google"; then
	icon="󰈟"
elif match "google drive" || match "drive.google"; then
	icon="󰊶"
elif match "google calendar" || match "calendar.google"; then
	icon=""
elif match "google chat" || match "chat.google"; then
	icon="󰭹"
elif match "google meet" || match "meet.google"; then
	icon="󰬗"
elif match "calendar"; then
	icon=""
elif match "notion"; then
	icon="󰊫"
elif match "figma"; then
	icon=""
elif match "canva"; then
	icon="󰔷"
elif match "youtube music" || match "yt music"; then
	icon="󰎇"
elif match "youtube"; then
	icon=""
elif match "netflix"; then
	icon="󰝆"
elif match "twitch"; then
	icon=""
elif match "x.com" || match "twitter"; then
	icon=""
elif match "reddit"; then
	icon="󰑍"
elif match "github"; then
	icon=""
elif match "gitlab"; then
	icon=""
elif match "stackoverflow"; then
	icon=""
elif match "chatgpt" || match "openai"; then
	icon="󱢆"
elif match "claude"; then
	icon="󱤙"
elif match "perplexity"; then
	icon="󱚣"
elif match "proton mail" || match "protonmail"; then
	icon=""
elif match "proton calendar" || match "protoncalendar"; then
	icon=""
elif match "proton drive" || match "protondrive"; then
	icon="󰋊"
elif match "proton vpn" || match "protonvpn"; then
	icon="󱂇"
elif match "proton pass" || match "protonpass"; then
	icon=""

# ───────────────────────────────────────────────
# Editors / IDEs
# ───────────────────────────────────────────────
elif match " code" || match "vscode" || match "visual studio code"; then
	icon="󰨞"
elif match "cursor"; then
	icon="󰨞"
elif match "windsurf"; then
	icon="󰨞"
elif match "sublime"; then
	icon=""
elif match "atom"; then
	icon=""
elif match "notepadqq"; then
	icon=""
elif match "intellij"; then
	icon=""
elif match "goland"; then
	icon=""
elif match "phpstorm"; then
	icon=""
elif match "rider"; then
	icon="󰚥"
elif match "rubymine"; then
	icon=""
elif match "datagrip"; then
	icon="󰆼"
elif match "pycharm"; then
	icon=""
elif match "webstorm"; then
	icon=""
elif match "clion"; then
	icon=""
elif match "android-studio"; then
	icon=""
elif match "qtcreator"; then
	icon="󰯲"
elif match "gedit"; then
	icon=""
elif match "kate"; then
	icon="󰦒"
elif match " vim" || match " nvim" || match "neovim"; then
	icon=""

# ───────────────────────────────────────────────
# File Managers
# ───────────────────────────────────────────────
elif match "nautilus" || match "org.gnome.nautilus"; then
	icon=""
elif match "dolphin"; then
	icon=""
elif match "nemo"; then
	icon=""
elif match "thunar"; then
	icon=""
elif match "pcmanfm"; then
	icon=""
elif match "doublecmd"; then
	icon="󰉋"

# ───────────────────────────────────────────────
# Chat / Communication
# ───────────────────────────────────────────────
elif match "discord"; then
	icon="󰙯"
elif match "slack"; then
	icon="󰒱"
elif match "telegram"; then
	icon=""
elif match "vesktop"; then
	icon="󰙯"
elif match "ferdium" || match "franz"; then
	icon="󰍡"
elif match "signal"; then
	icon="󰍪"
elif match "skype"; then
	icon=""
elif match "teams"; then
	icon="󰊻"
elif match "teamviewer"; then
	icon="󰢹"
elif match "zoom"; then
	icon=""
elif match "element"; then
	icon="󰫢"
elif match "mattermost"; then
	icon="󰍡"
elif match "webex"; then
	icon="󰬗"
elif match "hexchat"; then
	icon="󰬴"

# ───────────────────────────────────────────────
# Media Players
# ───────────────────────────────────────────────
elif match "spotify"; then
	icon="󰓇"
elif match "amberol"; then
	icon=""
elif match "vlc"; then
	icon="󰕼"
elif match "mpv"; then
	icon="󰍬"
elif match "plexamp"; then
	icon="󰚺"
elif match "stremio"; then
	icon="󰎆"
elif match "rhythmbox"; then
	icon="󰎆"
elif match "audacious"; then
	icon=""
elif match "clementine"; then
	icon="󰋋"

# ───────────────────────────────────────────────
# Office / Productivity
# ───────────────────────────────────────────────
elif match "libreoffice" || match "writer" || match "calc" || match "impress"; then
	icon="󰈬"
elif match "evince" || match "okular" || match "zathura"; then
	icon="󰈦"
elif match "gimp" || match "inkscape" || match "krita"; then
	icon=""
elif match "blender"; then
	icon="󰂫"
elif match "drawio"; then
	icon="󰕯"
elif match "clickup"; then
	icon="󰚸"
elif match "obsidian"; then
	icon="󱓧"

# ───────────────────────────────────────────────
# System Tools / Settings
# ───────────────────────────────────────────────
elif match "gnome-control-center" || match "systemsettings"; then
	icon=""
elif match "missioncenter"; then
	icon=""
elif match "gnome-disks" || match "gparted"; then
	icon=""
elif match "htop" || match "btop"; then
	icon="󰍛"
elif match "virt-manager" || match "virt-viewer"; then
	icon=""
elif match "virtualbox" || match "vmware" || match "qemu" || match "quickemu"; then
	icon="󰆧"
elif match "pavucontrol"; then
	icon="󰕾"
elif match "blueman"; then
	icon="󰂯"
elif match "nm-connection-editor" || match "network"; then
	icon="󰈀"
elif match "gnome-system-monitor"; then
	icon=""
elif match "timeshift"; then
	icon="󰋻"
elif match "synology"; then
	icon="󰣇"
elif match "nextcloud"; then
	icon="󰅩"
elif match "1password"; then
	icon="󰦝"
elif match "localsend"; then
	icon="󰇚"

# ───────────────────────────────────────────────
# Browsing / Misc Tools
# ───────────────────────────────────────────────
elif match "steam"; then
	icon="󰓓"
elif match "lutris" || match "heroic"; then
	icon="󰖺"
elif match "minecraft"; then
	icon="󰍳"
elif match "bottles"; then
	icon="󰡶"
elif match "obs"; then
	icon="󰨜"
elif match "filezilla"; then
	icon="󰏇"
elif match "transmission" || match "deluge" || match "qbittorrent"; then
	icon=""
elif match "jellyfin"; then
	icon="󰝚"
elif match "ark"; then
	icon=""
elif match "baobab"; then
	icon="󰋊"
elif match "xviewer" || match "eog" || match "gwenview"; then
	icon="󰈥"
elif match "flameshot" || match "spectacle" || match "grim" || match "swappy"; then
	icon=""
elif match "gnome-calendar"; then
	icon=""
elif match "keepassxc" || match "bitwarden"; then
	icon=""
elif match "burp"; then
	icon=""
elif match "wireshark" || match "zenmap"; then
	icon="󰲡"
elif match "postman" || match "insomnia"; then
	icon="󰘬"
elif match "docker" || match "lazydocker"; then
	icon="󰡨"
elif match "podman"; then
	icon="󰡨"
elif match "dbeaver"; then
	icon="󰆼"
elif match "beekeeper studio" || match "beekeeper-studio"; then
	icon="󰆼"
elif match "mongodb compass" || match "compass"; then
	icon=""
elif match "redis insight" || match "redisinsight"; then
	icon=""
elif match "yaak" || match "bruno"; then
	icon="󰘬"
elif match "remmina"; then
	icon="󰢹"

# ───────────────────────────────────────────────
# Browsers
# ───────────────────────────────────────────────
elif match "firefox"; then
	icon=""
elif match "vivaldi"; then
	icon="󰇩"
elif match "zen-browser" || match "zen browser"; then
	icon=""
elif match "google-chrome" || match "chrome" || match "chromium"; then
	icon=""
elif match "brave"; then
	icon=""
elif match "opera"; then
	icon=""
elif match "edge"; then
	icon="󰇩"
elif match "tor"; then
	icon=""
elif match "librewolf"; then
	icon=""
elif match "floorp"; then
	icon=""
elif match "epiphany" || match "gnome-web"; then
	icon=""

# ───────────────────────────────────────────────
# Terminals
# ───────────────────────────────────────────────
elif match "kitty"; then
	icon=""
elif match "alacritty"; then
	icon=""
elif match "ghostty"; then
	icon=""
elif match "konsole"; then
	icon=""
elif match "gnome-terminal"; then
	icon=""
elif match "xfce4-terminal"; then
	icon=""
elif match "tilix"; then
	icon=""
elif match "wezterm"; then
	icon=""
elif match "rio"; then
	icon=""
elif match "foot"; then
	icon=""
elif match "warp"; then
	icon=""
elif match "xterm"; then
	icon=""
elif match "guake"; then
	icon=""
elif match "yakuake"; then
	icon=""

fi

if [[ -z "$title" || "$title" == "null" ]]; then
	echo "" # print nothing
	exit 0
fi

# printf '{"text":"%s"}\n' "$icon"

# echo "  $icon "

maxlen=70
title=${title:0:$maxlen} # cut at 30 chars
if ((${#title} >= maxlen)); then
	title="${title}…" # add ellipsis if truncated
fi

#Print the icon and title
# printf " %s %s\n" "$icon" "$title"

#Print the icon ONLY
printf "%s\n" "$icon"

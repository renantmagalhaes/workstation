#!/bin/bash
#
# Hyprland Installation and Setup Script
# Author: Renan Toesqui Magalhães
#

FOLDER_LOCATION="$PWD"
DOTFILES="$HOME/.dotfiles"

check_cmd() {
    command -v "$1" 2>/dev/null
}

link_config() {
    SRC="$1"
    DEST="$2"

    if [ ! -e "$SRC" ]; then
        echo "⚠️ Missing source: $SRC, skipping."
        return
    fi

    rm -rf "$DEST"
    ln -s "$SRC" "$DEST"
    echo "🔗 Linked $DEST → $SRC"
}

echo "#################################"
echo "#   Hyprland Installation       #"
echo "#      and Setup Script         #"
echo "#################################"
echo ""

# Prevent running as root
if [ "$(id -u)" = "0" ]; then
    echo "Do not run this script as root"
    exit 1
fi

# Confirm OpenSUSE system
if ! check_cmd zypper; then
    echo "❌ This script only supports OpenSUSE"
    exit 1
fi

echo "✅ OpenSUSE detected"

###########################################
# DOTFILES MAIN SYMLINK
###########################################

echo "📁 Setting up main dotfiles symlink..."

SOURCE_DOTFILES="$FOLDER_LOCATION/dotfiles"

if [ -e "$DOTFILES" ]; then
    echo "ℹ️ ~/.dotfiles already exists, skipping."
else
    if [ ! -d "$SOURCE_DOTFILES" ]; then
        echo "❌ Source dotfiles folder not found at: $SOURCE_DOTFILES"
        exit 1
    fi
    ln -s "$SOURCE_DOTFILES" "$DOTFILES"
    echo "✅ Main dotfiles symlink created"
fi

###########################################
# SYSTEM INSTALLATION
###########################################

echo "🔄 Updating system..."
sudo zypper refresh && sudo zypper update

echo "📦 Installing core packages..."
sudo zypper install -y hyprland waybar wofi rofi playerctl pavucontrol hyprlock blueman hyprland-qtutils nwg-displays hypridle libevdev-devel evtest swappy grim slurp wl-clipboard mako pamixer xdg-desktop-portal-hyprland wireplumber python313-evdev python313-libevdev wlogout feh lxappearance scrot NetworkManager-applet pcp-pmda-lmsensors papirus-icon-theme pasystray jgmenu mate-polkit libnotify4 libnotify-devel libnotify-tools gnome-calendar cliphist gawk xdg-utils xcb-util-cursor-devel

echo "📦 Installing Hyprland extras..."
sudo zypper install -y hyprshot hyprpicker swww dunst kitty

###########################################
# USER FOLDERS
###########################################

mkdir -p "$HOME/GIT-REPOS/CORE"

###########################################
# HYPRLAND DESKTOP ENTRY
###########################################

echo "📝 Creating desktop entry..."
mkdir -p "$HOME/.local/share/applications"

cat >"$HOME/.local/share/applications/hyprland.desktop" <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Dynamic Wayland compositor
Exec=Hyprland
Type=Application
EOF

chmod +x "$HOME/.local/share/applications/hyprland.desktop"
update-desktop-database "$HOME/.local/share/applications"

###########################################
# BACKUP OLD CONFIGS
###########################################

if [ -d "$HOME/.config/hypr" ]; then
    echo "📦 Backing up existing Hyprland configuration..."
    cp -r "$HOME/.config/hypr" "$HOME/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)"
fi

###########################################
# SYMLINK CONFIG FOLDERS
###########################################

echo "📁 Linking configuration folders..."

link_config "$DOTFILES/hyprland/hypr" "$HOME/.config/hypr"
link_config "$DOTFILES/hyprland/waybar" "$HOME/.config/waybar"
link_config "$DOTFILES/mako" "$HOME/.config/mako"
link_config "$DOTFILES/rofi" "$HOME/.config/rofi"
link_config "$DOTFILES/hyprland/hypr/jgmenu" "$HOME/.config/jgmenu"
link_config "$DOTFILES/hyprland/waybar/extra/wlogout" "$HOME/.config/wlogout"

###########################################
# FIX NESTED ROFI FOLDER ISSUE
###########################################

if [ -d "$HOME/.config/rofi/rofi" ]; then
    echo "⚠️ Found nested rofi folder, fixing..."
    mv "$HOME/.config/rofi/rofi/"* "$HOME/.config/rofi/"
    rmdir "$HOME/.config/rofi/rofi"
fi

###########################################
# MAKE SCRIPTS EXECUTABLE
###########################################

if [ -d "$DOTFILES/hyprland/waybar/scripts" ]; then
    chmod +x "$DOTFILES/hyprland/waybar/scripts/"*.sh
fi

if [ -d "$DOTFILES/hyprland/hypr/scripts" ]; then
    chmod +x "$DOTFILES/hyprland/hypr/scripts/"*.sh
fi

###########################################
# CLIPHIST CONFIG
###########################################

if [ -f "$DOTFILES/hyprland/hypr/cliphist-config" ]; then
    mkdir -p "$HOME/.config/cliphist"
    echo "max-items 1000" >"$HOME/.config/cliphist/config"
fi

###########################################
# DONE
###########################################

echo ""
echo "🎉 Hyprland installation and setup completed successfully"
echo ""
echo "#################################"
echo "#        Setup Complete          #"
echo "#################################"

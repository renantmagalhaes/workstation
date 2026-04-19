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

SOURCE_DOTFILES="$FOLDER_LOCATION/dotfiles"

if [[ ! -L "$DOTFILES" ]] || [[ "$(readlink "$DOTFILES")" != "$SOURCE_DOTFILES" ]]; then
    echo "🔗 Setting up main dotfiles symlink..."
    if [ ! -d "$SOURCE_DOTFILES" ]; then
        echo "❌ Source dotfiles folder not found at: $SOURCE_DOTFILES"
        exit 1
    fi
    ln -sfn "$SOURCE_DOTFILES" "$DOTFILES"
    echo "✅ Main dotfiles symlink created"
else
    echo "ℹ️ ~/.dotfiles already exists and is correct, skipping."
fi

###########################################
# SYSTEM INSTALLATION
###########################################

echo "🔄 Updating system..."
sudo zypper refresh && sudo zypper update

echo "📦 Adding QuickShell repository..."
sudo zypper addrepo https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo
sudo zypper refresh

echo "📦 Installing core packages..."
sudo zypper install -y hyprland waybar wofi rofi playerctl pavucontrol hyprlock blueman hyprland-qtutils nwg-displays hypridle libevdev-devel evtest swappy grim slurp wl-clipboard mako pamixer xdg-desktop-portal-hyprland wireplumber python313-evdev python313-libevdev wlogout feh lxappearance scrot NetworkManager-applet pcp-pmda-lmsensors papirus-icon-theme pasystray jgmenu mate-polkit libnotify4 libnotify-devel libnotify-tools gnome-calendar cliphist gawk xdg-utils xcb-util-cursor-devel nautilus libpixman-1-0-devel pango-devel libudev1 hyprland-devel libinput-devel systemd-devel libdrm-devel libxkbcommon-devel wayland-devel glslang-devel
sudo zypper in -y patterns-hyprland-hyprland_extra

echo "📦 Installing Hyprland extras..."
sudo zypper install -y hyprshot hyprpicker awww dunst kitty quickshell-git

###########################################
# Add user groups
###########################################
sudo usermod -aG input $USER


###########################################
# USER FOLDERS
###########################################

mkdir -p "$HOME/GIT-REPOS/CORE"

###########################################
# QS-LAUNCHER
###########################################

echo "📥 Setting up QS-Launcher..."

QS_LAUNCHER_DIR="$HOME/.QS-Launcher"

if [ -d "$QS_LAUNCHER_DIR/.git" ]; then
    echo "ℹ️ QS-Launcher already cloned, skipping."
else
    rm -rf "$QS_LAUNCHER_DIR"
    git clone git@github.com:renantmagalhaes/QS-Launcher.git "$QS_LAUNCHER_DIR"
fi

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
# RUN POST INSTALL SCRIPTS
###########################################

echo "▶️ Running additional setup scripts..."

ROFI_SCRIPT="$FOLDER_LOCATION/scripts/rofi.sh"

if [ -f "$ROFI_SCRIPT" ]; then
    bash "$ROFI_SCRIPT"
    echo "✅ Rofi script executed"
else
    echo "⚠️ Rofi script not found at $ROFI_SCRIPT, skipping."
fi

# flameshot
mkdir -p "$HOME/.config/flameshot/"
echo -e "[General]\ndisabledGrimWarning=true\nuseGrimAdapter=true" > "$HOME/.config/flameshot/flameshot.ini"
echo "Config rewritten."

###########################################
# GTK THEME CONFIGURATION
###########################################

echo "🎨 Applying GTK theme settings..."

GTK3="$HOME/.config/gtk-3.0/settings.ini"
GTK4="$HOME/.config/gtk-4.0/settings.ini"

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

# Backup existing files if present
[ -f "$GTK3" ] && cp "$GTK3" "$GTK3.bkp"
[ -f "$GTK4" ] && cp "$GTK4" "$GTK4.bkp"

# Write GTK3 configuration
cat >"$GTK3" <<EOF
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-purple-light
gtk-font-name=Noto Sans, 10
gtk-cursor-theme-name=Fluent-dark-cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
gtk-cursor-blink=true
gtk-cursor-blink-time=1000
gtk-decoration-layout=icon:minimize,maximize,close
gtk-enable-animations=true
gtk-primary-button-warps-slider=true
gtk-sound-theme-name=ocean
gtk-xft-dpi=98304
EOF

# Write GTK4 configuration
cat >"$GTK4" <<EOF
[Settings]
gtk-theme-name=Graphite-Dark
gtk-icon-theme-name=Tela-circle-purple-light
gtk-font-name=Noto Sans, 10
gtk-cursor-theme-name=Fluent-dark-cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

# Export theme variables to shells
echo "export GTK_THEME=Graphite-Dark" >>"$HOME/.profile"
echo "export GTK_THEME=Graphite-Dark" >>"$HOME/.zprofile"

echo "🎨 GTK themes applied"

###########################################
# FORCE DARK MODE IN HYPRLAND
###########################################

echo "🌑 Enforcing dark mode globally..."

# Install required packages for color scheme handling
sudo zypper install -y gsettings-desktop-schemas kvantum-qt6

# Set GNOME and XDG color scheme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme Tela-circle-purple-light

###########################################
# DONE
###########################################

echo ""
echo "🎉 Hyprland installation and setup completed successfully"
echo ""
echo "#################################"
echo "#        Setup Complete          #"
echo "#################################"

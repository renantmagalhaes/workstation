#!/bin/bash
#
# Hyprland Installation and Setup Script
# This script installs Hyprland and sets up a complete environment
#
# Author: Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
# Site: https://insecure.codes
#

# Get current folder
FOLDER_LOCATION=$(pwd)

# check cmd function
check_cmd() {
	command -v "$1" 2>/dev/null
}

echo "#################################"
echo "#   Hyprland Installation      #"
echo "#      and Setup Script         #"
echo "#         insecure.codes        #"
echo "#################################"
echo ""

# Check if running as root
if [ "$(id -u)" = "0" ]; then
	echo "Don't run this script as root" 2>&1
	exit 1
fi

# Check if this is an OpenSUSE system
if ! check_cmd zypper; then
	echo "❌ This script only supports OpenSUSE systems"
	echo "Please use a supported OpenSUSE distribution"
	exit 1
fi

# Validate OpenSUSE system
echo "✅ OpenSUSE system detected"

# Create main dotfiles symlink
echo "📁 Setting up main dotfiles symlink..."
if [ -d "$FOLDER_LOCATION/../dotfiles" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.dotfiles ] || [ -d ~/.dotfiles ]; then
        rm -rf ~/.dotfiles
    fi
    ln -sf "$FOLDER_LOCATION/../dotfiles" ~/.dotfiles
    echo "✅ Main dotfiles symlink created"
else
    echo "❌ Dotfiles directory not found!"
    exit 1
fi

echo "🔄 Updating system packages..."
sudo zypper refresh && sudo zypper update

echo "📦 Installing Hyprland and core packages..."
sudo zypper install -y hyprland waybar wofi rofi playerctl pavucontrol hyprlock blueman hyprland-qtutils nwg-displays hypridle libevdev-devel evtest swappy grim slurp wl-clipboard mako pamixer xdg-desktop-portal-hyprland wireplumber python313-evdev python313-libevdev wlogout feh lxappearance scrot NetworkManager-applet pcp-pmda-lmsensors papirus-icon-theme pasystray jgmenu mate-polkit libnotify4 libnotify-devel libnotify-tools gnome-calendar

# Install Hyprland-specific packages
echo "📦 Installing Hyprland-specific packages..."
sudo zypper install -y hyprshot hyprpicker swww dunst kitty

# Install Wayland-specific packages
echo "📦 Installing Wayland packages..."
sudo zypper install -y wl-clipboard grim slurp

# Create user directories (only for directories that won't be symlinked)
echo "📁 Creating user directories..."
mkdir -p ~/GIT-REPOS/CORE

# Create desktop entry for Hyprland
echo "📝 Creating desktop entry..."
cat >~/.local/share/applications/hyprland.desktop <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Make desktop entry executable
chmod +x ~/.local/share/applications/hyprland.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications/

echo "✅ Hyprland installation completed"

# Check if Hyprland is installed
if ! command -v hyprland &> /dev/null; then
    echo "❌ Hyprland installation failed!"
    exit 1
fi

echo "✅ Hyprland is installed"

# Backup existing Hyprland config
if [ -d ~/.config/hypr ]; then
    echo "📦 Backing up existing Hyprland configuration..."
    cp -r ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
fi

echo "📁 Setting up configuration symlinks..."

# Create symlink for Hyprland configuration
echo "📋 Setting up Hyprland configuration..."
if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/hypr" ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/hypr ]; then
        rm -rf ~/.config/hypr
    fi
    # Create symlink
    ln -sf "$FOLDER_LOCATION/dotfiles/hyprland/hypr" ~/.config/hypr
    echo "✅ Hyprland configuration linked"
else
    echo "❌ Hyprland configuration directory not found!"
    exit 1
fi

# Create symlink for Waybar configuration
echo "📋 Setting up Waybar configuration..."
if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/waybar" ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/waybar ]; then
        rm -rf ~/.config/waybar
    fi
    # Create symlink
    ln -sf "$FOLDER_LOCATION/dotfiles/hyprland/waybar" ~/.config/waybar
    echo "✅ Waybar configuration linked"
else
    echo "❌ Waybar configuration directory not found!"
    exit 1
fi

# Mako configuration
echo "📋 Setting up Mako configuration..."
if [ -d "$FOLDER_LOCATION/dotfiles/mako" ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/mako ]; then
        rm -rf ~/.config/mako
    fi
    # Create symlink
    ln -sf "$FOLDER_LOCATION/dotfiles/mako" ~/.config/mako
    echo "✅ Mako configuration linked"
else
    echo "⚠️  Mako configuration directory not found, skipping..."
fi

# Create symlinks for shared scripts
echo "🔗 Setting up shared configurations..."

# Check for and fix nested folder issues
echo "🔍 Checking for nested folder issues..."
if [ -d ~/.config/rofi/rofi ]; then
    echo "⚠️  Found nested rofi folder, fixing..."
    mv ~/.config/rofi/rofi/* ~/.config/rofi/ 2>/dev/null || true
    rmdir ~/.config/rofi/rofi 2>/dev/null || true
fi

# Rofi scripts (if they exist)
if [ -d "$FOLDER_LOCATION/dotfiles/rofi" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/rofi ] || [ -d ~/.config/rofi ]; then
        rm -rf ~/.config/rofi
    fi
    ln -sf "$FOLDER_LOCATION/dotfiles/rofi" ~/.config/rofi
    echo "✅ Rofi configuration linked"
else
    echo "⚠️  Rofi configuration directory not found, skipping..."
fi

# Jgmenu configuration
echo "📋 Setting up Jgmenu configuration..."
if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/hypr/jgmenu" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/jgmenu ] || [ -d ~/.config/jgmenu ]; then
        rm -rf ~/.config/jgmenu
    fi
    ln -sf "$FOLDER_LOCATION/dotfiles/hyprland/hypr/jgmenu" ~/.config/jgmenu
    echo "✅ Jgmenu configuration linked"
else
    echo "⚠️  Jgmenu configuration directory not found, skipping..."
fi

# Wlogout configuration
echo "📋 Setting up Wlogout configuration..."
if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/waybar/extra/wlogout" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/wlogout ] || [ -d ~/.config/wlogout ]; then
        rm -rf ~/.config/wlogout
    fi
    ln -sf "$FOLDER_LOCATION/dotfiles/hyprland/waybar/extra/wlogout" ~/.config/wlogout
    echo "✅ Wlogout configuration linked"
else
    echo "⚠️  Wlogout configuration directory not found, skipping..."
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/waybar/scripts" ]; then
    chmod +x "$FOLDER_LOCATION/dotfiles/hyprland/waybar/scripts"/*.sh 2>/dev/null || true
    echo "✅ Waybar scripts made executable"
fi

if [ -d "$FOLDER_LOCATION/dotfiles/hyprland/hypr/scripts" ]; then
    chmod +x "$FOLDER_LOCATION/dotfiles/hyprland/hypr/scripts"/*.sh 2>/dev/null || true
    echo "✅ Hyprland scripts made executable"
fi

echo ""
echo "🎉 Hyprland installation and setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "✅ Hyprland - Wayland compositor installed"
echo "✅ Waybar - Status bar configured" 
echo "✅ Rofi - Application launcher configured"
echo "✅ Mako - Notification daemon configured"
echo "✅ BSPWM-style keybindings set up"
echo "✅ Visual effects configured"
echo "✅ Startup applications configured"
echo ""
echo "📋 Installed packages:"
echo "✅ Hyprland, Waybar, Rofi, Playerctl, Pavucontrol"
echo "✅ Hyprlock, Blueman, Dunst, Kitty"
echo "✅ Hyprshot/Hyprpicker, swww, wl-clipboard"
echo ""
echo "🚀 To start using Hyprland:"
echo "1. Log out of your current session"
echo "2. Select 'Hyprland' from your display manager"
echo "3. Or run: Hyprland"
echo ""
echo ""
echo "#################################"
echo "#     Setup Complete!          #"
echo "#         insecure.codes        #"
echo "#################################"

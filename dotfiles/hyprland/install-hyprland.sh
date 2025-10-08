#!/bin/bash
#
# Hyprland Installation Script for OpenSUSE
# This script installs Hyprland and all required packages
#
# Author: Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
# Site: https://rtm.codes
#

set -e

echo "#################################"
echo "#   Hyprland Installation      #"
echo "#      for OpenSUSE            #"
echo "#         rtm.codes             #"
echo "#################################"
echo ""

# Check if running as root
if [ "$(id -u)" = "0" ]; then
    echo "Don't run this script as root" 2>&1
    exit 1
fi

# Update system
echo "🔄 Updating system packages..."
sudo zypper refresh && sudo zypper update

# Install Hyprland and core packages (only Hyprland-specific)
echo "📦 Installing Hyprland and core packages..."
sudo zypper install -y hyprland waybar wofi rofi playerctl pavucontrol hyprlock blueman

# Install Hyprland-specific packages (not in system script)
echo "📦 Installing Hyprland-specific packages..."
sudo zypper install -y hyprshot hyprpicker swww dunst kitty

# Note: Flatpak applications should be installed via 2-opensuse-system.sh

# Install Wayland-specific packages (not in system script)
echo "📦 Installing Wayland packages..."
sudo zypper install -y wl-clipboard grim slurp

# Install optional Hyprland packages
echo "📦 Installing optional packages..."
sudo zypper install -y obs-studio discord telegram-desktop

# Create user directories
echo "📁 Creating user directories..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/dunst

# Set up environment variables
echo "🔧 Setting up environment variables..."
cat >> ~/.bashrc << 'EOF'

# Hyprland environment variables
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
EOF

# Create desktop entry for Hyprland
echo "📝 Creating desktop entry..."
cat > ~/.local/share/applications/hyprland.desktop << 'EOF'
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

echo ""
echo "🎉 Hyprland installation completed successfully!"
echo ""
echo "📋 Installed Hyprland-specific packages:"
echo "✅ Hyprland - Wayland compositor"
echo "✅ Waybar - Status bar"
echo "✅ Rofi - Application launcher"
echo "✅ Playerctl - Media controls"
echo "✅ Pavucontrol - Audio control"
echo "✅ Blueman - Bluetooth manager"
echo "✅ Dunst - Notification daemon"
echo "✅ Kitty - Terminal emulator"
echo "✅ Hyprshot/Hyprpicker - Screenshot tools"
echo "✅ swww - Wallpaper manager"
echo "✅ wl-clipboard - Clipboard tools"
echo ""
echo "📋 System packages (from 2-opensuse-system.sh):"
echo "✅ flameshot, alacritty, jgmenu, git, curl, wget"
echo "✅ vim, neovim, mpv, vlc, htop, neofetch, tree"
echo "✅ fd, ripgrep, bat, exa"
echo ""
echo "🚀 Next steps:"
echo "1. Run the setup script: ./hyprland-setup.sh"
echo "2. Log out and select 'Hyprland' from your display manager"
echo "3. Or run: Hyprland"
echo ""
echo "📖 Check the MIGRATION_GUIDE.md for detailed instructions"
echo ""
echo "#################################"
echo "#   Installation Complete!     #"
echo "#         rtm.codes             #"
echo "#################################"

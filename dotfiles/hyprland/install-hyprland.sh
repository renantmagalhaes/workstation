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

# Install Hyprland and core packages
echo "📦 Installing Hyprland and core packages..."
sudo zypper install -y hyprland waybar wofi rofi flameshot playerctl pavucontrol hyprlock jgmenu flatpak blueman

# Install additional useful packages
echo "📦 Installing additional packages..."
sudo zypper install -y hyprshot hyprpicker swww dunst kitty alacritty

# Install development tools (if needed)
echo "📦 Installing development tools..."
sudo zypper install -y git curl wget vim neovim

# Install flatpak applications
echo "📦 Installing flatpak applications..."
flatpak install -y flathub com.github.hluk.copyq

# Install media and graphics packages
echo "📦 Installing media packages..."
sudo zypper install -y mpv vlc clementine

# Install system utilities
echo "📦 Installing system utilities..."
sudo zypper install -y htop neofetch tree fd ripgrep bat exa

# Install Wayland-specific packages
echo "📦 Installing Wayland packages..."
sudo zypper install -y wl-clipboard grim slurp

# Install optional packages
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
echo "📋 Installed packages:"
echo "✅ Hyprland - Wayland compositor"
echo "✅ Waybar - Status bar"
echo "✅ Rofi - Application launcher"
echo "✅ Flameshot - Screenshot tool"
echo "✅ Playerctl - Media controls"
echo "✅ Pavucontrol - Audio control"
echo "✅ Blueman - Bluetooth manager"
echo "✅ Dunst - Notification daemon"
echo "✅ Kitty/Alacritty - Terminal emulators"
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

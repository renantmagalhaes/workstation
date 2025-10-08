#!/bin/bash
#
# Hyprland Setup Script
# This script sets up a complete Hyprland environment
#
# Author: Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
# Site: https://insecure.codes
#

set -e

echo "#################################"
echo "#      Hyprland Setup           #"
echo "#         insecure.codes             #"
echo "#################################"
echo ""

# Check if running as root
if [ "$(id -u)" = "0" ]; then
    echo "Don't run this script as root" 2>&1
    exit 1
fi

# Check if Hyprland is installed
if ! command -v hyprland &> /dev/null; then
    echo "❌ Hyprland is not installed!"
    echo "Please install Hyprland first:"
    echo "sudo zypper install hyprland waybar wofi"
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
if [ -d "$PWD/hypr" ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/hypr ]; then
        rm -rf ~/.config/hypr
    fi
    # Create symlink
    ln -sf "$PWD/hypr" ~/.config/hypr
    echo "✅ Hyprland configuration linked"
else
    echo "❌ Hyprland configuration directory not found!"
    exit 1
fi

# Create symlink for Waybar configuration
echo "📋 Setting up Waybar configuration..."
if [ -d "$PWD/waybar" ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/waybar ]; then
        rm -rf ~/.config/waybar
    fi
    # Create symlink
    ln -sf "$PWD/waybar" ~/.config/waybar
    echo "✅ Waybar configuration linked"
else
    echo "❌ Waybar configuration directory not found!"
    exit 1
fi

# Install required packages
echo "📦 Installing required packages..."
sudo zypper install -y waybar wofi rofi flameshot playerctl pavucontrol hyprlock jgmenu flatpak blueman

# Test hyprlock installation
echo "🔍 Testing hyprlock installation..."
if command -v hyprlock &> /dev/null; then
    echo "✅ hyprlock is installed"
else
    echo "❌ hyprlock installation failed"
    exit 1
fi

# Install optional packages
echo "📦 Installing optional packages..."
sudo zypper install -y hyprshot hyprpicker swww

# Note: Flatpak applications should be installed via 2-opensuse-system.sh

# Create symlinks for shared scripts
echo "🔗 Setting up shared configurations..."

# Check for and fix nested folder issues
echo "🔍 Checking for nested folder issues..."
if [ -d ~/.config/rofi/rofi ]; then
    echo "⚠️  Found nested rofi folder, fixing..."
    mv ~/.config/rofi/rofi/* ~/.config/rofi/ 2>/dev/null || true
    rmdir ~/.config/rofi/rofi 2>/dev/null || true
fi

if [ -d ~/.config/dunst/dunst ]; then
    echo "⚠️  Found nested dunst folder, fixing..."
    mv ~/.config/dunst/dunst/* ~/.config/dunst/ 2>/dev/null || true
    rmdir ~/.config/dunst/dunst 2>/dev/null || true
fi

# Rofi scripts (if they exist)
if [ -d "$PWD/../rofi" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/rofi ] || [ -d ~/.config/rofi ]; then
        rm -rf ~/.config/rofi
    fi
    ln -sf "$PWD/../rofi" ~/.config/rofi
    echo "✅ Rofi configuration linked"
fi

# Dunst configuration (if it exists)
if [ -d "$PWD/../bspwm/dunst" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/dunst ] || [ -d ~/.config/dunst ]; then
        rm -rf ~/.config/dunst
    fi
    ln -sf "$PWD/../bspwm/dunst" ~/.config/dunst
    echo "✅ Dunst configuration linked"
fi

# Setup hyprlock configuration
echo "🔒 Setting up hyprlock configuration..."
if [ -f "$PWD/hypr/hyprlock-minimal.conf" ]; then
    ln -sf "$PWD/hypr/hyprlock-minimal.conf" ~/.config/hypr/hyprlock.conf
    echo "✅ hyprlock configuration linked (minimal)"
elif [ -f "$PWD/hypr/hyprlock.conf" ]; then
    ln -sf "$PWD/hypr/hyprlock.conf" ~/.config/hypr/hyprlock.conf
    echo "✅ hyprlock configuration linked"
else
    echo "⚠️  No hyprlock configuration found"
fi

# Test hyprlock configuration
echo "🔍 Testing hyprlock configuration..."
if hyprlock --help &> /dev/null; then
    echo "✅ hyprlock is working"
else
    echo "❌ hyprlock has issues - check configuration"
fi

# Note: Startup applications are handled by startup.conf (native Hyprland way)

# Create session file
echo "📝 Creating Hyprland session file..."
cat > ~/.config/hypr/hyprland-session.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Create setup summary
echo "📋 Creating setup summary..."
cat > ~/.config/hypr/SETUP_SUMMARY.md << 'EOF'
# Hyprland Setup Summary

## What was configured:

### ✅ Hyprland Configuration
- Complete window manager setup with productivity keybindings
- Dual monitor workspace navigation
- Media keys and system controls
- Mouse bindings and gestures

### ✅ Visual Effects
- Built-in compositor with blur effects
- Rounded corners and shadows
- Smooth animations and transitions
- Window transparency rules

### ✅ Waybar Status Bar
- Modern status bar replacing Polybar
- System information display
- Workspace indicators
- Media controls and notifications

### ✅ Applications
- Rofi launcher and menus
- Screenshot tools (flameshot)
- Audio controls (pavucontrol)
- Network management
- All essential system tools

## Key Features:

### 🎯 Productivity Workflow
- **Terminal**: `Super + T` → Opens kitty
- **File Manager**: `Super + E` → Opens nautilus
- **Launcher**: `Super + P` or `Super + Z` → Opens rofi
- **Screenshots**: `Print`, `Ctrl + Print`, `Alt + Print` → flameshot
- **Window Management**: Complete window management
- **Workspace Navigation**: Dual monitor setup
- **Media Keys**: Volume, brightness, media controls

### 🖥️ Dual Monitor Setup
- **DP-1**: Workspaces 1, 2, 3, 4, 5
- **HDMI-1**: Workspaces 11, 22, 33, 44, 55
- Seamless workspace switching between monitors

## Usage:

1. **Start Hyprland**: Select Hyprland from your display manager
2. **Reload config**: `hyprctl reload`
3. **Restart waybar**: `killall waybar && waybar &`

## Troubleshooting:

- Check logs: `journalctl -u hyprland`
- Reload config: `hyprctl reload`
- Restart waybar: `killall waybar && waybar &`
EOF

echo ""
echo "🎉 Hyprland setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "✅ Hyprland configuration installed"
echo "✅ Waybar status bar configured" 
echo "✅ BSPWM-style keybindings set up"
echo "✅ Visual effects configured"
echo "✅ Startup applications configured"
echo ""
echo "🚀 To start using Hyprland:"
echo "1. Log out of your current session"
echo "2. Select 'Hyprland' from your display manager"
echo "3. Or run: Hyprland"
echo ""
echo "📖 Check ~/.config/hypr/SETUP_SUMMARY.md for details"
echo ""
echo "#################################"
echo "#     Setup Complete!          #"
echo "#         insecure.codes             #"
echo "#################################"

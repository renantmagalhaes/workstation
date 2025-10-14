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

# MAKO
echo "📋 Setting up Waybar configuration..."
if [ -d ../mako/ ]; then
    # Remove existing directory if it exists
    if [ -d ~/.config/mako ]; then
        rm -rf ~/.config/mako
    fi
    # Create symlink
    ln -sf "$HOME/.dotfiles/mako" ~/.config/mako
    echo "✅ Mako configuration linked"
else
    echo "❌ Waybar configuration directory not found!"
    exit 1
fi


# Note: Package installation is handled by install-hyprland.sh

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

# Rofi scripts (if they exist)
if [ -d "$PWD/../rofi" ]; then
    # Remove existing symlink or directory if it exists
    if [ -L ~/.config/rofi ] || [ -d ~/.config/rofi ]; then
        rm -rf ~/.config/rofi
    fi
    ln -sf "$PWD/../rofi" ~/.config/rofi
    echo "✅ Rofi configuration linked"
fi

# Note: hyprlock configuration is handled by the hypr/ symlink

# Note: Startup applications are handled by startup.conf (native Hyprland way)

# Note: Desktop session file not required - Hyprland is auto-detected by display managers


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

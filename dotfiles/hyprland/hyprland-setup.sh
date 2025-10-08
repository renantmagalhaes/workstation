#!/bin/bash
#
# Hyprland Setup Script
# This script sets up a complete Hyprland environment
#
# Author: Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
# Site: https://rtm.codes
#

set -e

echo "#################################"
echo "#      Hyprland Setup           #"
echo "#         rtm.codes             #"
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

# Create Hyprland config directory
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar

echo "📁 Created configuration directories"

# Copy Hyprland configuration
echo "📋 Setting up Hyprland configuration..."
if [ -f "$PWD/hypr/hyprland-migrated.conf" ]; then
    cp "$PWD/hypr/hyprland-migrated.conf" ~/.config/hypr/hyprland.conf
    echo "✅ Hyprland configuration copied"
else
    echo "❌ Hyprland configuration file not found!"
    exit 1
fi

# Copy Waybar configuration
echo "📋 Setting up Waybar configuration..."
if [ -f "$PWD/waybar/config-migrated.jsonc" ]; then
    cp "$PWD/waybar/config-migrated.jsonc" ~/.config/waybar/config
    echo "✅ Waybar configuration copied"
else
    echo "❌ Waybar configuration file not found!"
    exit 1
fi

# Copy Waybar style
if [ -f "$PWD/waybar/style.css" ]; then
    cp "$PWD/waybar/style.css" ~/.config/waybar/
    echo "✅ Waybar style copied"
fi

# Copy Waybar scripts
if [ -d "$PWD/waybar/scripts" ]; then
    cp -r "$PWD/waybar/scripts" ~/.config/waybar/
    chmod +x ~/.config/waybar/scripts/*.sh
    echo "✅ Waybar scripts copied"
fi

# Copy Waybar icons
if [ -d "$PWD/waybar/icons" ]; then
    cp -r "$PWD/waybar/icons" ~/.config/waybar/
    echo "✅ Waybar icons copied"
fi

# Install required packages
echo "📦 Installing required packages..."
sudo zypper install -y waybar wofi rofi flameshot playerctl pavucontrol blueman-manager hyprlock tdrop jgmenu xdotool flatpak

# Install optional packages
echo "📦 Installing optional packages..."
sudo zypper install -y hyprshot hyprpicker swww

# Install flatpak applications
echo "📦 Installing flatpak applications..."
flatpak install -y flathub com.github.hluk.copyq

# Create symlinks for shared scripts
echo "🔗 Setting up shared configurations..."

# Rofi scripts (if they exist)
if [ -d "$PWD/../rofi" ]; then
    ln -sf "$PWD/../rofi" ~/.config/rofi
    echo "✅ Rofi configuration linked"
fi

# Dunst configuration (if it exists)
if [ -d "$PWD/../bspwm/dunst" ]; then
    ln -sf "$PWD/../bspwm/dunst" ~/.config/dunst
    echo "✅ Dunst configuration linked"
fi

# Create startup script
echo "🚀 Creating Hyprland startup script..."
cat > ~/.config/hypr/startup.sh << 'EOF'
#!/bin/bash
# Hyprland startup script

# Start essential services
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
nm-applet &
dunst &
kdeconnectd &
kdeconnect-indicator &
flatpak run com.github.hluk.copyq &
/usr/bin/1password --silent &
# swww-daemon is already started above

# swww-daemon is already started above

# Start waybar
waybar &

# Set up monitors
hyprctl keyword monitor "DP-1,2560x1440@143.91,0x0,1"
hyprctl keyword monitor "HDMI-1,2560x1440@143.91,2560x0,1"

echo "Hyprland startup complete!"
EOF

chmod +x ~/.config/hypr/startup.sh

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
echo "#         rtm.codes             #"
echo "#################################"

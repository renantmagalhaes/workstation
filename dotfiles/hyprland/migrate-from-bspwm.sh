#!/bin/bash
#
# Hyprland Setup Script
# This script sets up a complete Hyprland environment with BSPWM-style workflow
#
# Author: Renan Toesqui Magalhães <renantmagalhaes@gmail.com>
# Site: https://rtm.codes
#

set -e

echo "#################################"
echo "#      Hyprland Setup           #"
echo "#    BSPWM-style Workflow       #"
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

# Copy migrated configuration files
echo "📋 Copying migrated configuration files..."

# Copy Hyprland configuration
if [ -f "$PWD/hypr/hyprland-migrated.conf" ]; then
    cp "$PWD/hypr/hyprland-migrated.conf" ~/.config/hypr/hyprland.conf
    echo "✅ Hyprland configuration copied"
else
    echo "❌ Hyprland configuration file not found!"
    exit 1
fi

# Copy Waybar configuration
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
sudo zypper install -y waybar wofi rofi flameshot playerctl pavucontrol blueman-manager

# Install optional packages
echo "📦 Installing optional packages..."
sudo zypper install -y hyprshot hyprpicker swww nitrogen

# Create symlinks for shared scripts
echo "🔗 Creating symlinks for shared scripts..."

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

# BSPWM scripts (for compatibility)
if [ -d "$PWD/../bspwm/scripts" ]; then
    ln -sf "$PWD/../bspwm/scripts" ~/.config/hypr/scripts
    echo "✅ BSPWM scripts linked for compatibility"
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
nitrogen --restore &

# Start swww for wallpaper management
swww-daemon &

# Start waybar
waybar &

# Set up monitors (matching your BSPWM setup)
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

# Create migration summary
echo "📋 Creating migration summary..."
cat > ~/.config/hypr/MIGRATION_SUMMARY.md << 'EOF'
# BSPWM to Hyprland Migration Summary

## What was migrated:

### ✅ Keybindings
- All BSPWM keybindings converted to Hyprland format
- Dual monitor workspace navigation preserved
- Media keys and system controls maintained
- Mouse bindings adapted for Hyprland

### ✅ Visual Effects
- Blur effects migrated to Hyprland's built-in compositor
- Rounded corners and shadows configured
- Animations preserved and enhanced
- Opacity rules converted to window rules

### ✅ Applications
- Polybar replaced with Waybar
- Picom removed (Hyprland has built-in compositing)
- Rofi launcher maintained
- All startup applications preserved

### ✅ Workspace Setup
- Dual monitor configuration maintained
- Workspace assignments preserved
- Window rules migrated

## What's different:

### 🔄 Polybar → Waybar
- More modern and feature-rich
- Better Wayland integration
- Enhanced customization options

### 🔄 Picom → Built-in Compositor
- No external compositor needed
- Better performance
- Native Wayland support

### 🔄 sxhkd → Built-in Keybindings
- All keybindings in Hyprland config
- Better integration with window manager
- More reliable key handling

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
echo "🎉 Migration completed successfully!"
echo ""
echo "📋 Summary:"
echo "✅ Hyprland configuration migrated"
echo "✅ Waybar configuration migrated" 
echo "✅ Keybindings converted"
echo "✅ Visual effects preserved"
echo "✅ Startup applications configured"
echo ""
echo "🚀 To start using Hyprland:"
echo "1. Log out of your current session"
echo "2. Select 'Hyprland' from your display manager"
echo "3. Or run: Hyprland"
echo ""
echo "📖 Check ~/.config/hypr/MIGRATION_SUMMARY.md for details"
echo ""
echo "#################################"
echo "#     Migration Complete!       #"
echo "#         rtm.codes             #"
echo "#################################"

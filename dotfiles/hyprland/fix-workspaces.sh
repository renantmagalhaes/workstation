#!/bin/bash

echo "🔧 Fixing workspace visibility in Waybar..."

# Backup current config
if [ -f ~/.config/waybar/config.jsonc ]; then
    cp ~/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc.backup
    echo "✅ Backed up current Waybar config"
fi

# Use the workspace-optimized config
if [ -f "$PWD/waybar/config-workspaces.jsonc" ]; then
    ln -sf "$PWD/waybar/config-workspaces.jsonc" ~/.config/waybar/config.jsonc
    echo "✅ Applied workspace-optimized Waybar config"
else
    echo "❌ Workspace config not found"
    exit 1
fi

# Restart Waybar
echo "🔄 Restarting Waybar..."
pkill waybar 2>/dev/null || true
sleep 1
waybar &
echo "✅ Waybar restarted"

# Test workspace visibility
echo "🔍 Testing workspace visibility..."
sleep 2

# Check if all workspaces are visible
workspace_count=$(hyprctl workspaces | grep -c "workspace")
echo "📊 Found $workspace_count workspaces"

if [ "$workspace_count" -ge 10 ]; then
    echo "✅ All workspaces should now be visible in Waybar"
else
    echo "⚠️  Only $workspace_count workspaces found"
    echo "💡 Try creating windows on different workspaces to test"
fi

echo "🎉 Workspace fix completed!"
echo ""
echo "📋 What was changed:"
echo "  ✅ Added persistent-workspaces configuration"
echo "  ✅ Set active-only: false"
echo "  ✅ Added show-special: true"
echo "  ✅ Added workspace icons"
echo "  ✅ Restarted Waybar"
echo ""
echo "💡 If workspaces still don't show:"
echo "  1. Try switching to different workspaces"
echo "  2. Check if monitors are properly detected"
echo "  3. Restart Hyprland completely"

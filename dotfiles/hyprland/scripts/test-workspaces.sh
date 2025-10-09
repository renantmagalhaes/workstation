#!/bin/bash

# Test script to verify Hyprland workspace configuration
echo "🔍 Testing Hyprland Workspace Configuration"
echo "=============================================="

# Check if Hyprland is running
if ! pgrep -x "Hyprland" > /dev/null; then
    echo "❌ Hyprland is not running"
    echo "   Please start Hyprland first to test workspace configuration"
    exit 1
fi

echo "✅ Hyprland is running"

# Test workspace commands
echo ""
echo "📋 Testing workspace commands:"
echo "-------------------------------"

# List current workspaces
echo "Current workspaces:"
hyprctl workspaces | grep -E "workspace [0-9]+" || echo "No workspaces found"

# Test workspace switching using the workspace_action.sh script
echo ""
echo "Testing workspace switching with workspace_action.sh..."
for i in {1..5}; do
    echo "Switching to workspace $i..."
    ~/.config/hypr/scripts/workspace_action.sh workspace $i
    sleep 0.5
done

echo ""
echo "✅ Workspace test completed"
echo ""
echo "🎯 Expected behavior:"
echo "   - 5 workspaces (1-5) should be available"
echo "   - Workspaces should be shared across all monitors"
echo "   - Super + 1-5 should switch workspaces (using workspace_action.sh)"
echo "   - Ctrl + Super + Left/Right should cycle workspaces"
echo "   - Mouse scroll on Super should switch workspaces"
echo "   - Workspace swipe gestures should work (4-finger swipe)"

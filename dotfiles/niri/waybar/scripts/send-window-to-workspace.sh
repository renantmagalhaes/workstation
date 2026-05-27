#!/bin/bash
# Niri-compatible script to send the focused window/column to a selected workspace.

# Get current focused window
focused_info=$(niri msg -j windows | jq '.[] | select(.is_focused == true)')
if [ -z "$focused_info" ] || [ "$focused_info" = "null" ]; then
    notify-send -i error "Niri" "No focused window found"
    exit 1
fi

# Select workspace (1-5) using rofi
selected_space=$(echo -e "1\n2\n3\n4\n5" | rofi -dmenu -p "Send window to workspace:")

# Check if a workspace was selected
if [ -n "$selected_space" ]; then
    niri msg action move-column-to-workspace "$selected_space"
fi

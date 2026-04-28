#!/bin/bash

# Direction argument (left or right)
direction=$1

# Get focused monitor information
monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
monitor_width=$(echo "$monitor" | jq -r '.width')
monitor_x=$(echo "$monitor" | jq -r '.x')
active_workspace=$(echo "$monitor" | jq -r '.activeWorkspace.id')

# Monitor edges
left_edge=$monitor_x
right_edge=$((monitor_x + monitor_width))

# Get all clients on the active workspace
clients=$(hyprctl clients -j | jq -r --argjson ws "$active_workspace" '
  .[] | select(.workspace.id == $ws and .mapped == true and .hidden == false)
')

output=""

if [ "$direction" = "left" ]; then
    # Check for windows on the left
    windows_on_left=$(echo "$clients" | jq -r --argjson edge "$left_edge" '
      select(.at[0] < $edge) | .address
    ')
    if [ -n "$windows_on_left" ]; then
        output=" 󰁍 "
    fi
elif [ "$direction" = "right" ]; then
    # Check for windows on the right
    windows_on_right=$(echo "$clients" | jq -r --argjson edge "$right_edge" '
      select((.at[0] + .size[0]) > $edge) | .address
    ')
    if [ -n "$windows_on_right" ]; then
        output=" 󰁔 "
    fi
fi

echo "$output"

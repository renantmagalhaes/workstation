#!/bin/bash
direction=$1

# Get monitor info
monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
monitor_width=$(echo "$monitor" | jq -r '.width')
monitor_x=$(echo "$monitor" | jq -r '.x')
active_workspace=$(echo "$monitor" | jq -r '.activeWorkspace.id')
right_edge=$((monitor_x + monitor_width))

# Perform a single robust check for all windows on the workspace
status=$(hyprctl clients -j | jq -r --argjson ws "$active_workspace" --argjson left "$monitor_x" --argjson right "$right_edge" '
  [ .[] | select(.workspace.id == $ws and .mapped == true and .hidden == false) ] as $clients |
  {
    left: (any($clients[]; .at[0] < $left)),
    right: (any($clients[]; (.at[0] + .size[0]) > $right))
  } |
  "\(.left) \(.right)"
')

read -r has_left has_right <<< "$status"

if [ "$direction" = "left" ] && [ "$has_left" = "true" ]; then
    echo " 󰁍 "
elif [ "$direction" = "right" ] && [ "$has_right" = "true" ]; then
    echo " 󰁔 "
else
    echo ""
fi

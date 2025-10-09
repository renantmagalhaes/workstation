#!/bin/bash

# # Launch kitty and move it to magic workspace
# kitty &
# sleep 1
# hyprctl dispatch movetoworkspace special:kitty
# sleep 0.3
# hyprctl dispatch togglespecialworkspace
#
#
HYPRLAND_INSTANCE_SIGNATURE=$(echo "$HYPRLAND_INSTANCE_SIGNATURE")
HYPRLAND_CMD="hyprctl --instance $HYPRLAND_INSTANCE_SIGNATURE"

$HYPRLAND_CMD dispatch exec "[workspace special:kitty silent]" kitty

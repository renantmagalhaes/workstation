#!/usr/bin/env bash
# Workspace action script for Hyprland
# Usage: workspace_action.sh <action> <workspace_number>

# Get the action and workspace number
action="$1"
workspace_num="$2"

# Execute the hyprctl command
hyprctl dispatch "$action" "$workspace_num"

#!/bin/bash

# Monitor configuration - matches other Hyprland scripts
PRIMARY="${PRIMARY_MONITOR:-DP-1}"
SECONDARY="${SECONDARY_MONITOR:-HDMI-A-1}"

# Get the current workspace of the focused window
current_space=$(hyprctl -j activewindow | jq -r '.workspace.id // empty')

# Check if there is a focused window
if [ -z "$current_space" ]; then
    echo "No focused window."
    exit 1
fi

# Show only primary monitor workspaces (1-5) for selection
# These pair with secondary workspaces 6-10
spaces=$(seq 1 5)

# Annotate the current space in the list of spaces
# If window is on workspace 1-5, show that as current
# If window is on workspace 6-10, show the corresponding primary (n-5) as current
if [[ "$current_space" =~ ^[0-9]+$ ]]; then
    if (( current_space >= 1 && current_space <= 5 )); then
        current_display="$current_space"
    elif (( current_space >= 6 && current_space <= 10 )); then
        current_display=$((current_space - 5))
    else
        current_display=""
    fi
else
    current_display=""
fi

# Annotate the current workspace in the list
if [ -n "$current_display" ]; then
    annotated_spaces=$(echo "$spaces" | sed "s/^$current_display\$/$current_display (current)/")
else
    annotated_spaces="$spaces"
fi

# Use rofi to select a workspace
selected_space=$(echo "$annotated_spaces" | rofi -theme menu.rasi -dmenu -p "Select workspace:" | sed 's/ (current)//')

# Check if a workspace was selected
if [ -z "$selected_space" ]; then
    echo "No workspace selected."
    exit 1
fi

# Validate that selected workspace is 1-5
if ! [[ "$selected_space" =~ ^[1-5]$ ]]; then
    echo "Invalid workspace selected: $selected_space"
    exit 1
fi

# Calculate the paired workspace
# Workspace 1 pairs with 6, 2 with 7, 3 with 8, 4 with 9, 5 with 10
paired_workspace=$((selected_space + 5))

# Determine which workspace to move the window to based on its current location
# If window is on primary (1-5), move to selected primary workspace
# If window is on secondary (6-10), move to corresponding secondary workspace
if [[ "$current_space" =~ ^[0-9]+$ ]]; then
    if (( current_space >= 6 && current_space <= 10 )); then
        # Window is on secondary monitor, move to secondary workspace
        target_workspace="$paired_workspace"
        target_monitor="$SECONDARY"
    else
        # Window is on primary or elsewhere, move to primary workspace
        target_workspace="$selected_space"
        target_monitor="$PRIMARY"
    fi
else
    # Default to primary if workspace ID is not numeric
    target_workspace="$selected_space"
    target_monitor="$PRIMARY"
fi

# Move the focused window to the target workspace
hyprctl dispatch movetoworkspace "$target_workspace"

# Sync both monitors to show the paired workspaces
sleep 0.02
hyprctl dispatch focusmonitor "$PRIMARY"
sleep 0.02
hyprctl dispatch workspace "$selected_space"
sleep 0.02
hyprctl dispatch focusmonitor "$SECONDARY"
sleep 0.02
hyprctl dispatch workspace "$paired_workspace"

# Return focus to the monitor where the window was moved
sleep 0.02
hyprctl dispatch focusmonitor "$target_monitor"

echo "Moved window to workspace $target_workspace and synced monitors (primary: $selected_space, secondary: $paired_workspace)."

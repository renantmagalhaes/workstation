#!/bin/bash

# Get the window ID of the currently active window
window_id=$(xdotool getactivewindow)

# Get the position of the window using xwininfo
window_position=$(xwininfo -id "$window_id" | grep "Absolute upper-left X:")

# Extract the window's X coordinate
window_x=$(echo "$window_position" | awk '{print $4}')

# Get information about connected monitors and their positions
monitor_info=$(xrandr | grep " connected")

# Initialize variables to store monitor width and action
selected_monitor_width=""
action=""

# Iterate through each line of monitor information to find the one containing the window's position
while IFS= read -r line; do
    if [[ $line =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
        monitor_width="${BASH_REMATCH[1]}"
        monitor_height="${BASH_REMATCH[2]}"
        monitor_x="${BASH_REMATCH[3]}"
        monitor_y="${BASH_REMATCH[4]}"

        if ((window_x >= monitor_x && window_x < monitor_x + monitor_width)); then
            selected_monitor_width="$monitor_width"
            break
        fi
    fi
done <<< "$monitor_info"

# Perform actions based on selected monitor width
if [[ "$selected_monitor_width" == "2560" ]]; then
    xdotool keydown Shift Super Right
    xdotool keyup Shift Super
    action="Shift+Super+Right"
elif [[ "$selected_monitor_width" == "1920" ]]; then
    xdotool keydown Shift Super Left
    xdotool keyup Shift Super
    action="Shift+Super+Left"
fi

# Print monitor information and action
if [[ -n "$selected_monitor_width" ]]; then
    echo "Current window is on Monitor: $monitor_width x $monitor_height at $monitor_x,$monitor_y"
    echo "Performing action: $action"
    sleep 0.1  # Give some time for the keys to be recognized
    # xdotool keyup Shift Super
else
    echo "Could not determine current monitor."
fi

#!/bin/bash

# Get the current monitor ID of the active window
current_monitor_id=$(hyprctl activewindow -j | jq -r '.monitor')

# Get all monitors with their IDs and names
monitors_json=$(hyprctl monitors -j)

# Extract monitor names in order
monitor_names=$(echo "$monitors_json" | jq -r '.[].name')

# Convert to array
monitor_array=($monitor_names)

# Find current monitor name by ID
current_monitor_name=$(echo "$monitors_json" | jq -r ".[$current_monitor_id].name")

# Find current monitor index in the array
current_index=-1
for i in "${!monitor_array[@]}"; do
    if [[ "${monitor_array[$i]}" == "$current_monitor_name" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next monitor index (cycle back to 0 if at the end)
if [ $current_index -eq -1 ]; then
    # If current monitor not found, default to first monitor
    next_index=0
else
    next_index=$(( (current_index + 1) % ${#monitor_array[@]} ))
fi

# Move window to next monitor
next_monitor="${monitor_array[$next_index]}"
hyprctl dispatch movewindow mon:"$next_monitor"

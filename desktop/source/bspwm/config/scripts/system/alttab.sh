#!/bin/bash

# Function to map workspace number to its pair
map_workspace_to_pair() {
    case "$1" in
        1) echo "11" ;;
        2) echo "22" ;;
        3) echo "33" ;;
        4) echo "44" ;;
        5) echo "55" ;;
        11) echo "1" ;;
        22) echo "2" ;;
        33) echo "3" ;;
        44) echo "4" ;;
        55) echo "5" ;;
        *) echo "unknown" ;;
    esac
}

# Get the name of the currently focused desktop
focused_desktop=$(bspc query -D -d focused --names)

# Map the focused desktop to its pair
paired_desktop=$(map_workspace_to_pair "$focused_desktop")

# Get a list of windows on the currently focused desktop and its pair
windows_on_desktops=$(bspc query -N -d "$focused_desktop" -n .window; bspc query -N -d "$paired_desktop" -n .window)

# Convert the list into an array
windows=($windows_on_desktops)

# Get the ID of the currently focused node
focused_node=$(bspc query -N -n)

# Find the index of the currently focused window in the array
focused_index=-1
for i in "${!windows[@]}"; do
   if [[ "${windows[$i]}" = "$focused_node" ]]; then
       focused_index=$i
       break
   fi
done

# Determine the next window to focus
next_index=$(( (focused_index + 1) % ${#windows[@]} ))

# Focus the next window
if [[ $next_index -ne -1 && ${#windows[@]} -gt 0 ]]; then
    bspc node "${windows[$next_index]}" -f
fi

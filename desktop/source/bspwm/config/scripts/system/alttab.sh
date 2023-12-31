#!/bin/bash

# Function to map workspace number to its pair
map_workspace_to_pair() {
    local workspace=$1

    # Query the names of workspaces on each monitor
    local workspaces_monitor1=($(bspc query -D -m DisplayPort-0 --names))
    local workspaces_monitor2=($(bspc query -D -m HDMI-A-0 --names))

    # Determine the index of the workspace in its monitor's list
    local index=-1
    for i in "${!workspaces_monitor1[@]}"; do
        if [[ "${workspaces_monitor1[$i]}" == "$workspace" ]]; then
            index=$i
            break
        fi
    done

    # If found on the first monitor, get the corresponding workspace from the second monitor
    if [[ $index -ne -1 ]]; then
        echo "${workspaces_monitor2[$index]}"
        return
    fi

    # Repeat for the second monitor
    for i in "${!workspaces_monitor2[@]}"; do
        if [[ "${workspaces_monitor2[$i]}" == "$workspace" ]]; then
            index=$i
            break
        fi
    done

    if [[ $index -ne -1 ]]; then
        echo "${workspaces_monitor1[$index]}"
    else
        echo "unknown"
    fi
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

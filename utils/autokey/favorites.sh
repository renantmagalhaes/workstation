#!/bin/bash

# Function to get the active window ID
get_active_window_id() {
    xdotool getactivewindow
}

# Function to get the active window name
get_active_window_name() {
    xdotool getwindowname $(get_active_window_id)
}

# Get the active window's name
window_name=$(get_active_window_name)
echo "$window_name"

# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name =~ Microsoft.+Edge ]]; then
    # Activate (focus and raise) the Microsoft Edge window
    xdotool windowactivate $(get_active_window_id)
    # Introduce a delay to ensure the window is activated
    sleep 1
    # Simulate Ctrl+Shift+O using xdotool
    xdotool key ctrl+shift+o
else
    echo "Active window is not Microsoft Edge."
fi

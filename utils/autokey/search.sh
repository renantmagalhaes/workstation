#!/bin/bash


# Get the active window's name
window_name=$(xdotool getactivewindow getwindowname |grep Edge |awk '{print $NF}')
echo "$window_name"

# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name == "Edge" ]]; then
    # Simulate Ctrl+Shift+O using xdotool
    sleep 0.1
    xdotool key ctrl+shift+a
else
    sleep 0.1
    xdotool key F2
    echo "Active window is not Microsoft Edge."
fi

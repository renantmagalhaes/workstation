#!/bin/bash


# Get the active window's name
window_name=$(xdotool getactivewindow getwindowname)
echo "$window_name"

# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name =~ Microsoft.+Edge ]]; then
    # Simulate Ctrl+Shift+O using xdotool
    sleep 0.1
    xdotool key ctrl+shift+o

else
    echo "Active window is not Microsoft Edge."
fi

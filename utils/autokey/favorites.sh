#!/bin/bash


# Get the active window's name
window_name=$(xdotool getactivewindow getwindowname |grep Edge |awk '{print $NF}')
echo "$window_name"

# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name == "Edge" ]]; then
    # Simulate Ctrl+Shift+O using xdotool
    sleep 0.1
    xdotool key ctrl+shift+o
else
    sleep 0.1
    sleep 0.1
    pkill sxhkd
    sleep 0.1
    xdotool key ctrl+space
    sleep 0.1
    sxhkd &
fi

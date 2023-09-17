#!/bin/bash


# Get the active window's name
window_name=$(xdotool getactivewindow getwindowname |grep Edge |awk '{print $NF}')
edge_search_window_name=$(xdotool getactivewindow getwindowname)


# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name == "Edge" ]]; then
    # Simulate Ctrl+Shift+O using xdotool
    sleep 0.1
    xdotool key ctrl+shift+a
    sleep 0.1
    while [[ $edge_search_window_name != "" ]]
    do
        sleep 0.2
        edge_search_window_name=$(xdotool getactivewindow getwindowname)
    done
    xdotool key ctrl+shift+F12
else
    sleep 0.1
    pkill sxhkd
    sleep 0.1
    xdotool key F2
    sleep 0.1
    sxhkd &
fi

#!/bin/bash


# Get the active window's name
window_name=$(xdotool getactivewindow getwindowname |grep Edge |awk '{print $NF}')
edge_search_window_name=$(xdotool getactivewindow getwindowname)


# Check if the window name contains "Microsoft" followed by any character and then "Edge"
if [[ $window_name == "Edge" ]]; then
    # Simulate Ctrl+Shift+O using xdotool
    sleep 0.1
    xdotool key ctrl+shift+a
else
    sleep 0.1
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ binding '<Control><Shift>F2'
    sleep 0.1
    xdotool key F2
    sleep 0.1
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ binding 'F2'
fi

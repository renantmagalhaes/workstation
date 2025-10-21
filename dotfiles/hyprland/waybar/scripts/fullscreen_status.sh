#!/bin/bash

# Get the fullscreen state of the active window
fullscreen_state=$(hyprctl activewindow -j | jq -r '.fullscreen')

if [ "$fullscreen_state" = "1" ]; then
    # Window is fullscreen, show exit fullscreen icon
    echo "󰊴"
else
    # Window is not fullscreen, show enter fullscreen icon
    echo "󰊓"
fi

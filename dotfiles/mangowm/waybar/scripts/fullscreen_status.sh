#!/bin/bash

# Get the fullscreen state of the active monitor in MangoWM
active_monitor=$(mmsg -g | awk '$2=="selmon" && $3=="1" {print $1}')
if [ -n "$active_monitor" ]; then
    fullscreen_state=$(mmsg -g | awk -v mon="$active_monitor" '$1==mon && $2=="fullscreen" {print $3}')
else
    fullscreen_state="0"
fi

if [ "$fullscreen_state" = "1" ]; then
    # Window is fullscreen, show exit fullscreen icon
    echo ""
else
    # Window is not fullscreen, show enter fullscreen icon
    echo "󰊓"
fi

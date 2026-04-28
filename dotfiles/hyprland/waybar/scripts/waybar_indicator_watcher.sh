#!/bin/bash

# Get the numeric value of SIGRTMIN (usually 34)
RTMIN=$(kill -l SIGRTMIN 2>/dev/null || echo 34)

# Function to poke Waybar to refresh the indicators
update_waybar() {
    # Send signals 42, 43, and 44 (RTMIN+8, +9, +10)
    kill -$(($RTMIN + 8)) $(pidof waybar) 2>/dev/null
    kill -$(($RTMIN + 9)) $(pidof waybar) 2>/dev/null
    kill -$(($RTMIN + 10)) $(pidof waybar) 2>/dev/null
}

# Initial update
update_waybar

# Socket path
SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Fallback socket detection
if [ ! -S "$SOCKET_PATH" ]; then
    SOCKET_PATH=$(find "$XDG_RUNTIME_DIR/hypr" -name ".socket2.sock" | head -n 1)
fi

# Final fallback to polling if no socket found
if [ ! -S "$SOCKET_PATH" ]; then
    while true; do update_waybar; sleep 1; done
fi

# Listen to Hyprland events
# Added 'fullscreen' to the events list
socat -U - UNIX-CONNECT:"$SOCKET_PATH" | while read -r line; do
    case "$line" in
        workspace*|movewindow*|openwindow*|closewindow*|focuswindow*|activewindow*|fullscreen*|layoutmsg*)
            update_waybar
            ;;
    esac
done

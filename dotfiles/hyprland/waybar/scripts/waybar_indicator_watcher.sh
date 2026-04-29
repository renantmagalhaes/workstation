#!/bin/bash

# Give Waybar and Hyprland a moment to start to avoid race conditions during signal handler setup
sleep 2

# Get the numeric value of SIGRTMIN (usually 34)
RTMIN=$(kill -l SIGRTMIN 2>/dev/null || echo 34)

# Function to poke Waybar to refresh the indicators
update_waybar() {
    # Find Waybar PIDs
    local pids=$(pidof waybar)
    
    if [ -n "$pids" ]; then
        # Send signals 42, 43, and 44 (RTMIN+8, +9, +10)
        # These correspond to "signal": 8, 9, 10 in Waybar config
        for pid in $pids; do
            kill -$(($RTMIN + 8)) "$pid" 2>/dev/null
            kill -$(($RTMIN + 9)) "$pid" 2>/dev/null
            kill -$(($RTMIN + 10)) "$pid" 2>/dev/null
        done
    fi
}

# Initial update to sync state
update_waybar

# Function to get the current Hyprland socket path
get_socket_path() {
    local path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    if [ ! -S "$path" ]; then
        # Fallback: find any hyprland socket if the signature-based one is missing
        path=$(find "$XDG_RUNTIME_DIR/hypr" -name ".socket2.sock" 2>/dev/null | head -n 1)
    fi
    echo "$path"
}

# Main resilient loop
while true; do
    SOCKET_PATH=$(get_socket_path)

    if [ -S "$SOCKET_PATH" ]; then
        # Listen to Hyprland events
        # We use socat to stream events and refresh waybar on relevant ones
        socat -U - UNIX-CONNECT:"$SOCKET_PATH" | while read -r line; do
            case "$line" in
                workspace*|movewindow*|openwindow*|closewindow*|focuswindow*|activewindow*|fullscreen*|layoutmsg*)
                    update_waybar
                    ;;
            esac
        done
        # If socat exits (e.g. Hyprland restart), we will loop back and try to reconnect
    else
        # If no socket found, do a single update and wait before retrying
        update_waybar
    fi
    
    # Wait a bit before retrying to connect or polling
    sleep 2
done


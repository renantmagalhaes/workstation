#!/bin/bash

# Give Waybar and MangoWM a moment to start to avoid race conditions
sleep 2

# Get the numeric value of SIGRTMIN (usually 34)
RTMIN=$(kill -l SIGRTMIN 2>/dev/null || echo 34)

# Function to poke Waybar to refresh the indicators
update_waybar() {
    # Find main Waybar PID only
    local pids=$(pgrep -f "waybar -c .*[c]onfig.jsonc")
    
    if [ -n "$pids" ]; then
        # Send signal 10 (RTMIN+10) corresponding to "signal": 10 in Waybar config for fullscreen
        for pid in $pids; do
            kill -$(($RTMIN + 10)) "$pid" 2>/dev/null
        done
    fi
}

# Initial update to sync state
update_waybar

# Main resilient loop listening to MangoWM events via mmsg -w
while true; do
    if command -v mmsg >/dev/null 2>&1; then
        mmsg -w | while read -r line; do
            case "$line" in
                *selmon*|*tag*|*title*|*fullscreen*|*layout*|*floating*)
                    update_waybar
                    ;;
            esac
        done
    else
        # If mmsg not found, do a single update and wait before retrying
        update_waybar
    fi
    
    sleep 2
done

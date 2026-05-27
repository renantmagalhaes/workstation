#!/bin/bash
# Simple watcher that signals Waybar to update scroll and fullscreen indicators when workspace, layout, or window focus changes.

sleep 2

RTMIN=$(kill -l SIGRTMIN 2>/dev/null || echo 34)

update_waybar() {
    # Send signals 8 (scroll indicators) and 10 (fullscreen status/indicators) to waybar
    local pids=$(pgrep -f "waybar -c")
    if [ -n "$pids" ]; then
        for pid in $pids; do
            kill -$(($RTMIN + 8)) "$pid" 2>/dev/null
            kill -$(($RTMIN + 10)) "$pid" 2>/dev/null
        done
    fi
}

update_waybar

# Stream Niri events and trigger updates immediately
if command -v niri >/dev/null 2>&1; then
    niri msg --json event-stream | while read -r line; do
        update_waybar
    done
else
    # Fallback to polling if niri command is not found
    while true; do
        update_waybar
        sleep 2
    done
fi

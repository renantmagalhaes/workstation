#!/bin/bash
# Simple watcher that signals Waybar to update scroll indicators when active tag or focus changes.
# No daemons, no background Python processes.

sleep 2

RTMIN=$(kill -l SIGRTMIN 2>/dev/null || echo 34)

update_waybar() {
    local pids=$(pgrep -f "waybar -c .*[c]onfig.jsonc")
    if [ -n "$pids" ]; then
        for pid in $pids; do
            kill -$(($RTMIN + 8)) "$pid" 2>/dev/null
        done
    fi
}

update_waybar

while true; do
    if command -v mmsg >/dev/null 2>&1; then
        mmsg -w | while read -r line; do
            case "$line" in
                *selmon*|*tag*|*layout*|*width*|*height*|*fullscreen*|*floating*)
                    update_waybar
                    ;;
            esac
        done
    else
        update_waybar
    fi
    sleep 3
done

#!/bin/bash

# Temporary file for cached battery status
TEMP_FILE="/tmp/mouse_battery_status.txt"
CACHE_DURATION=300 # Cache valid for 300 seconds (5 minutes)

# Check if the cache file exists and is fresh
if [[ -f "$TEMP_FILE" && $(($(date +%s) - $(stat -c %Y "$TEMP_FILE"))) -lt $CACHE_DURATION ]]; then
    # Read battery status from cache
    mouse_battery=$(cat "$TEMP_FILE")
else
    # Query battery status and update cache
    mouse_battery=$(solaar show | grep -A 2 'MX Master' | grep 'Battery' | awk '{print $2}' | sed 's/,$//')
    mouse_battery=${mouse_battery:-"Not Found"}

    # Save to cache
    echo "$mouse_battery" >"$TEMP_FILE"
fi

# Create notification message
message="🔋 🖱️ Logitech MX Master 3S: $mouse_battery"

# Send notification via Dunst
notify-send "Peripheral Battery Status" "$message" -i battery -u normal -t 5000

#!/usr/bin/env bash
# Watchdog script to monitor and restart waybar and mouse_actions.py
# Checks every 10 seconds and relaunches if processes are not running

set -euo pipefail

# Path to mouse_actions.py script
MOUSE_ACTIONS_SCRIPT="$HOME/.config/hypr/scripts/mouse_actions.py"

# Function to check if a process is running
is_running() {
    local process_name="$1"
    pgrep -x "$process_name" >/dev/null 2>&1
}

# Function to launch waybar
launch_waybar() {
    if ! is_running "waybar"; then
        waybar >/dev/null 2>&1 &
    fi
}

# Function to launch mouse_actions.py
launch_mouse_actions() {
    # Check specifically for mouse_actions.py process
    if ! pgrep -f "mouse_actions.py" >/dev/null 2>&1; then
        python3 "$MOUSE_ACTIONS_SCRIPT" >/dev/null 2>&1 &
    fi
}

# Main loop
while true; do
    launch_waybar
    launch_mouse_actions
    sleep 10
done

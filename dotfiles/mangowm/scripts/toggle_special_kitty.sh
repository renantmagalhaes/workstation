#!/usr/bin/env bash

# Scratchpad launch command (uses tmux to preserve shell state across window close/kill events)
LAUNCH_CMD="kitty --class kitty-scratch -T kitty-scratch tmux new -A -s kitty-scratch"

# Find out if kitty-scratch is currently running
if ! pgrep -f "kitty-scratch" > /dev/null; then
    # It does not exist yet. Spawn it (will trigger native zoom-in popup animation)
    $LAUNCH_CMD &
    exit 0
fi

# Get current focused monitor name
mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1; exit}')
if [ -z "$mon" ]; then
    mon=$(mmsg -O | head -n 1)
fi

# Find out if kitty-scratch is currently focused on the active monitor
focused_appid=$(mmsg -g | awk -v m="$mon" '$1==m && $2=="appid" {print $3; exit}')

if [ "$focused_appid" = "kitty-scratch" ]; then
    # It is currently focused. Close/kill it (will trigger native zoom-out collapse animation)
    mmsg -s -d killclient
else
    # It is running but unfocused. Focus it instantly (no animation), then kill it (collapse animation)
    mmsg -s -d setoption,animations,0
    mmsg -s -d toggle_named_scratchpad,kitty-scratch,none,"$LAUNCH_CMD"
    mmsg -s -d setoption,animations,1
    mmsg -s -d killclient
fi

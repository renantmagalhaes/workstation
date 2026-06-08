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
if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

mon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .name')
if [ -z "$mon" ]; then
    mon=$(mmsg get all-monitors | jq -r '.monitors[0].name')
fi

# Find out if kitty-scratch is currently focused on the active monitor
focused_appid=$(mmsg get focusing-client | jq -r '.appid // empty')

if [ "$focused_appid" = "kitty-scratch" ]; then
    # It is currently focused. Close/kill it (will trigger native zoom-out collapse animation)
    mmsg dispatch killclient
else
    # It is running but unfocused. Focus it instantly (no animation), then kill it (collapse animation)
    mmsg dispatch setoption,animations,0
    mmsg dispatch toggle_named_scratchpad,kitty-scratch,none,"$LAUNCH_CMD"
    mmsg dispatch setoption,animations,1
    mmsg dispatch killclient
fi

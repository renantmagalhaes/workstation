#!/usr/bin/env bash
if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

current_mon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .name')
other_mon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active | not) | .name' | head -n 1)

if [ -n "$other_mon" ]; then
    mmsg dispatch focusmon,"$other_mon"
fi

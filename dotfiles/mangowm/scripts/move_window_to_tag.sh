#!/usr/bin/env bash
direction=$1

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

current=$(mmsg get all-monitors | jq '.monitors[] | select(.active) | .active_tags[0]')

if ! [[ "$current" =~ ^[0-9]+$ ]]; then
    current=1
fi

if [ "$direction" = "left" ]; then
    new=$((current - 1))
    if [ $new -lt 1 ]; then new=1; fi
else
    new=$((current + 1))
    if [ $new -gt 5 ]; then new=5; fi
fi

mmsg dispatch tag,$new,1
mmsg dispatch view,$new,1

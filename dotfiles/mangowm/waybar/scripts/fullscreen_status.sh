#!/bin/bash

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

fullscreen_state=$(mmsg get focusing-client | jq -r '.is_fullscreen // "false"')

if [ "$fullscreen_state" = "true" ]; then
    # Window is fullscreen, show exit fullscreen icon
    echo ""
else
    # Window is not fullscreen, show enter fullscreen icon
    echo "󰊓"
fi

#!/usr/bin/env bash

declare -A initial_overview

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

for mon in $(mmsg get all-monitors | jq -r '.monitors[].name'); do
    initial_overview["$mon"]=$(mmsg get all-monitors | jq -r --arg m "$mon" '.monitors[] | select(.name == $m) | if .active_tags[0] == 0 then "true" else "false" end')
done

while true; do
    sleep 0.1
    mode=$(mmsg get keymode | jq -r '.keymode')
    if [ "$mode" != "overview" ]; then
        exit 0
    fi

    for mon in $(mmsg get all-monitors | jq -r '.monitors[].name'); do
        is_overview=$(mmsg get all-monitors | jq -r --arg m "$mon" '.monitors[] | select(.name == $m) | if .active_tags[0] == 0 then "true" else "false" end')
        
        layout_changed=false
        if [ "${initial_overview["$mon"]}" = "true" ] && [ "$is_overview" = "false" ]; then
            layout_changed=true
        fi
        if [ "$layout_changed" = true ]; then
            # A window was selected. Get the current active monitor.
            current_mon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .name')
            
            # Get the active tag of the selected window's monitor
            selected_tag=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .active_tags[0]')
            
            # Disable overview on all monitors and synchronize their active tag
            for m in $(mmsg get all-monitors | jq -r '.monitors[].name'); do
                is_m_overview=$(mmsg get all-monitors | jq -r --arg mon "$m" '.monitors[] | select(.name == $mon) | if .active_tags[0] == 0 then "true" else "false" end')
                if [ "$is_m_overview" = "true" ]; then
                    mmsg dispatch focusmon,"$m"
                    mmsg dispatch toggleoverview
                fi
                
                if [ "$m" != "$current_mon" ] && [ -n "$selected_tag" ]; then
                    mmsg dispatch focusmon,"$m"
                    mmsg dispatch view,"$selected_tag",1
                fi
            done
            
            # Focus back on the monitor where the window was selected
            if [ -n "$current_mon" ]; then
                mmsg dispatch focusmon,"$current_mon"
            fi
            
            mmsg dispatch setkeymode,default
            exit 0
        fi
    done
done

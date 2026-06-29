#!/usr/bin/env bash
current_mon=$(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | .name')
mode=$(mmsg get keymode | jq -r '.keymode')

if [ "$mode" = "overview" ]; then
    # We are exiting overview mode. Toggle off any monitors that are still in overview.
    for mon in $(mmsg get all-monitors | jq -r '.monitors[].name'); do
        is_ov=$(mmsg get all-monitors | jq -r --arg m "$mon" '.monitors[] | select(.name == $m) | if .active_tags[0] == 0 then "true" else "false" end')
        if [ "$is_ov" = "true" ]; then
            mmsg dispatch focusmon,"$mon"
            mmsg dispatch toggleoverview
        fi
    done
    mmsg dispatch setkeymode,default
else
    # We are entering overview mode. Toggle on any monitors that are not in overview.
    for mon in $(mmsg get all-monitors | jq -r '.monitors[].name'); do
        is_ov=$(mmsg get all-monitors | jq -r --arg m "$mon" '.monitors[] | select(.name == $m) | if .active_tags[0] == 0 then "true" else "false" end')
        if [ "$is_ov" = "false" ]; then
            mmsg dispatch focusmon,"$mon"
            mmsg dispatch toggleoverview
        fi
    done
    mmsg dispatch setkeymode,overview
    ~/.dotfiles/mangowm/scripts/watch_overview.sh &
fi

if [ -n "$current_mon" ]; then
    mmsg dispatch focusmon,"$current_mon"
fi

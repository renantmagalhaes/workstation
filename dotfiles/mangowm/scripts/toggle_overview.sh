#!/usr/bin/env bash
mmsg dispatch toggleoverview
mode=$(mmsg get keymode | jq -r '.keymode')
if [ "$mode" = "overview" ]; then
    mmsg dispatch setkeymode,default
else
    mmsg dispatch setkeymode,overview
    /home/rtm/GIT-REPOS/workstation/dotfiles/mangowm/scripts/watch_overview.sh &
fi

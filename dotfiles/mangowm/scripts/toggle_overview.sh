#!/usr/bin/env bash
mmsg -d toggleoverview
mode=$(mmsg -g -b | awk '$2 == "keymode" {print $3; exit}')
if [ "$mode" = "overview" ]; then
    mmsg -d setkeymode,default
else
    mmsg -d setkeymode,overview
    /home/rtm/GIT-REPOS/workstation/dotfiles/mangowm/scripts/watch_overview.sh &
fi

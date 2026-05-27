#!/usr/bin/env bash
current_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')
mode=$(mmsg -g -b | awk '$2 == "keymode" {print $3; exit}')

for mon in $(mmsg -O); do
    mmsg -d focusmon,"$mon"
    mmsg -d toggleoverview
done

if [ -n "$current_mon" ]; then
    mmsg -d focusmon,"$current_mon"
fi

if [ "$mode" = "overview" ]; then
    mmsg -d setkeymode,default
else
    mmsg -d setkeymode,overview
    /home/rtm/GIT-REPOS/workstation/dotfiles/mangowm/scripts/watch_overview.sh &
fi

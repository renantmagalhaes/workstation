#!/usr/bin/env bash
current_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')
mode=$(mmsg -g -b | awk '$2 == "keymode" {print $3; exit}')

if [ "$mode" = "overview" ]; then
    # We are exiting overview mode. Toggle off any monitors that are still in overview.
    for mon in $(mmsg -O); do
        layout=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "layout" {print $3; exit}')
        if [ "$layout" = "󰃇" ]; then
            mmsg -d focusmon,"$mon"
            mmsg -d toggleoverview
        fi
    done
    mmsg -d setkeymode,default
else
    # We are entering overview mode. Toggle on any monitors that are not in overview.
    for mon in $(mmsg -O); do
        layout=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "layout" {print $3; exit}')
        if [ "$layout" != "󰃇" ]; then
            mmsg -d focusmon,"$mon"
            mmsg -d toggleoverview
        fi
    done
    mmsg -d setkeymode,overview
    ~/.dotfiles/mangowm/scripts/watch_overview.sh &
fi

if [ -n "$current_mon" ]; then
    mmsg -d focusmon,"$current_mon"
fi

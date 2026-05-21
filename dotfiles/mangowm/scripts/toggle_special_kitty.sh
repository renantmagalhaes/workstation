#!/usr/bin/env bash

# Get current focused monitor name and tag
mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1; exit}')
if [ -z "$mon" ]; then
    mon=$(mmsg -O | head -n 1)
fi
tag=$(mmsg -g | awk -v m="$mon" '$1==m && $2=="tag" && $4=="1" {print $3; exit}')

# Find out if kitty-scratch is currently visible on this monitor
visible_on_mon=$(mmsg -g | awk -v m="$mon" '$1==m && ($2=="title" || $2=="appid") && $3=="kitty-scratch" {print $1; exit}')

# If it exists and is already visible on the current monitor, just toggle it to hide it!
if [ -n "$visible_on_mon" ]; then
    mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty --class kitty-scratch -T kitty-scratch"
    exit 0
fi

# Otherwise, if it already exists, we bring it over to the current monitor/tag
if pgrep -f "kitty-scratch" > /dev/null; then
    # Toggle it (which brings it over/shows it)
    mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty --class kitty-scratch -T kitty-scratch"
    
    # Wait for focus and bring the window over to the current monitor and tag
    sleep 0.1
    mmsg -d tagcrossmon,"$tag","$mon"
    exit 0
fi

# It does not exist yet. Let's create it.
mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty --class kitty-scratch -T kitty-scratch"

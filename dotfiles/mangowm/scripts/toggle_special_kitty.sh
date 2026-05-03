#!/usr/bin/env bash

# Get current focused monitor name and tag
mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1; exit}')
if [ -z "$mon" ]; then
    mon=$(mmsg -O | head -n 1)
fi
tag=$(mmsg -g | awk -v m="$mon" '$1==m && $2=="tag" && $4=="1" {print $3; exit}')

# Find out if kitty-scratch is currently visible on this monitor
visible_on_mon=$(mmsg -g | awk -v m="$mon" '$1==m && $2=="title" && $3=="kitty-scratch" {print $1; exit}')

# If it exists and is already visible on the current monitor, just toggle it to hide it!
if [ -n "$visible_on_mon" ]; then
    mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty -T kitty-scratch"
    exit 0
fi

# Otherwise, if it already exists, we bring it over to the current monitor/tag
if pgrep -f "kitty -T kitty-scratch" > /dev/null; then
    # Toggle it (which brings it over/shows it)
    mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty -T kitty-scratch"
    
    # Wait for focus and bring the window over to the current monitor and tag
    sleep 0.1
    mmsg -d tagcrossmon,"$tag","$mon"
    exit 0
fi

# It does not exist yet. Let's create it.
# Get usable dimensions and position of this monitor from mmsg -g
w=$(mmsg -g | grep "^$mon " | awk '$2 == "width" {print $3; exit}')
h=$(mmsg -g | grep "^$mon " | awk '$2 == "height" {print $3; exit}')
mx=$(mmsg -g | grep "^$mon " | awk '$2 == "x" {print $3; exit}')
my=$(mmsg -g | grep "^$mon " | awk '$2 == "y" {print $3; exit}')

if [ -z "$w" ] || [ -z "$h" ]; then
    w=1920
    h=1080
    mx=0
    my=0
fi

# Calculate 95% of width and height
nw=$(awk -v width="$w" 'BEGIN {print int(width * 0.95)}')
nh=$(awk -v height="$h" 'BEGIN {print int(height * 0.95)}')

# Centered window position
tx=$(awk -v x="$mx" -v mw="$w" -v nw="$nw" 'BEGIN {print int(x + (mw - nw) / 2)}')
ty=$(awk -v y="$my" -v mh="$h" -v nh="$nh" 'BEGIN {print int(y + (mh - nh) / 2)}')

# Toggle the named scratchpad
mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty -T kitty-scratch"

# Briefly pause, resize, and move to centered position
sleep 0.1
mmsg -d resizewin,"$nw","$nh"
mmsg -d movewin,"$tx","$ty"

#!/usr/bin/env bash

# If it exists, just toggle it and exit without any resizing!
if pgrep -f "kitty -T kitty-scratch" > /dev/null; then
    mmsg -d toggle_named_scratchpad,none,kitty-scratch,"kitty -T kitty-scratch"
    exit 0
fi

# It does not exist yet. Let's create it.
# Get current focused monitor name
mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1; exit}')
if [ -z "$mon" ]; then
    mon=$(mmsg -O | head -n 1)
fi

# Get dimensions and position of this monitor from mmsg -g
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

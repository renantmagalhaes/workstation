#!/usr/bin/env bash
A_1080=250
B_1080=250

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
resolution=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
hypr_scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')
wlogout -C $HOME/.config/waybar/extra/wlogout/nova.css -l $HOME/.config/waybar/extra/wlogout/layout --protocol layer-shell -b 4 -T 200 -B 200 &

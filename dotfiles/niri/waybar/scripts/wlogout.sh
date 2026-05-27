#!/usr/bin/env bash

# Check if wlogout is already running
# if pgrep -f "wlogout" > /dev/null; then
#     pkill -f "wlogout"
#     exit 0
# fi

wlogout -C $HOME/.dotfiles/niri/waybar/extra/wlogout/nova.css -l $HOME/.dotfiles/niri/waybar/extra/wlogout/layout --protocol layer-shell -b 4 -T 200 -B 200 &

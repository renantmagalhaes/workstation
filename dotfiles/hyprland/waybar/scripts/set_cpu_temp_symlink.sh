#!/bin/bash
# Find the k10temp hwmon directory and create a stable symlink for Waybar

for hwmon in /sys/class/hwmon/hwmon*; do
    if [ "$(cat "$hwmon/name" 2>/dev/null)" = "k10temp" ]; then
        ln -sf "$hwmon/temp1_input" ~/.config/waybar/cpu_temp
        break
    fi
done

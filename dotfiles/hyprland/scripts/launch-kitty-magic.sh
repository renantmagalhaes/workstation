#!/bin/bash

# Launch kitty and move it to magic workspace
kitty &
sleep 1
hyprctl dispatch movetoworkspace special:kitty

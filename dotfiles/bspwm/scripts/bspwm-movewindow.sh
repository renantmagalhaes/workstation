#!/bin/bash

# Check for direction argument
if [ "$1" != "next" ] && [ "$1" != "prev" ]; then
  echo "Usage: $0 {next|prev}"
  exit 1
fi

# Get the ID of the current focused window and the current desktop
current_window=$(bspc query -N -n focused)
current_desktop=$(bspc query -D -d focused --names)

# Define explicit transitions for each workspace
case "$current_desktop" in
  "1")
    next_desktop="2"
    prev_desktop="5"
    ;;
  "2")
    next_desktop="3"
    prev_desktop="1"
    ;;
  "3")
    next_desktop="4"
    prev_desktop="2"
    ;;
  "4")
    next_desktop="5"
    prev_desktop="3"
    ;;
  "5")
    next_desktop="1"
    prev_desktop="4"
    ;;
  "11")
    next_desktop="22"
    prev_desktop="55"
    ;;
  "22")
    next_desktop="33"
    prev_desktop="11"
    ;;
  "33")
    next_desktop="44"
    prev_desktop="22"
    ;;
  "44")
    next_desktop="55"
    prev_desktop="33"
    ;;
  "55")
    next_desktop="11"
    prev_desktop="44"
    ;;
  *)
    echo "Unknown workspace: $current_desktop"
    exit 1
    ;;
esac

# Determine the target desktop based on the direction
if [ "$1" == "next" ]; then
  target_desktop="$next_desktop"
else
  target_desktop="$prev_desktop"
fi

# Move the window to the target desktop
bspc node "$current_window" -d "$target_desktop"

# Refocus on the target desktop and the moved window
bspc desktop -f "$target_desktop"
bspc node -f "$current_window"

# Ensure the correct monitor is focused
target_monitor=$(bspc query -M -d "$target_desktop")
bspc monitor -f "$target_monitor"


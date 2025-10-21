#!/usr/bin/env bash
set -euo pipefail

# Pairing model:
#   PRIMARY uses workspaces 1..5
#   SECONDARY uses workspaces 6..10, paired as n+5
PRIMARY="DP-1"
SECONDARY="HDMI-A-1"

DIR="${1:-next}"       # next | prev
WRAP="${2:-0}"         # 0 clamp at ends, 1 wrap around

command -v hyprctl >/dev/null

# Get focused window’s current workspace (numeric)
cur_ws="$(hyprctl -j activewindow | jq -r '.workspace.id // empty')"
[[ "$cur_ws" =~ ^[0-9]+$ ]] || exit 0

# Figure which rail we are on and normalize to a base 1..5 index
if (( cur_ws >= 1 && cur_ws <= 5 )); then
  rail="primary"
  base="$cur_ws"               # 1..5 already
elif (( cur_ws >= 6 && cur_ws <= 10 )); then
  rail="secondary"
  base=$((cur_ws - 5))         # map 6..10 -> 1..5
else
  # Outside our scheme, do nothing
  exit 0
fi

step() {
  local n="$1"
  if [[ "$DIR" == "next" ]]; then
    if (( n < 5 )); then echo $((n+1))
    else
      if (( WRAP == 1 )); then echo 1
      else echo 5
      fi
    fi
  else
    if (( n > 1 )); then echo $((n-1))
    else
      if (( WRAP == 1 )); then echo 5
      else echo 1
      fi
    fi
  fi
}

target_base="$(step "$base")"

# Compute target workspace number for the window and for each monitor focus
if [[ "$rail" == "primary" ]]; then
  win_target="$target_base"           # move window within 1..5
else
  win_target=$((target_base + 5))     # move window within 6..10
fi

primary_target="$target_base"         # PRIMARY shows n
secondary_target=$((target_base + 5)) # SECONDARY shows n+5

# Move the window first, then align monitors
hyprctl dispatch movetoworkspace "$win_target"

sleep 0.02
hyprctl dispatch focusmonitor "$PRIMARY"
sleep 0.02
hyprctl dispatch workspace "$primary_target"
sleep 0.02
hyprctl dispatch focusmonitor "$SECONDARY"
sleep 0.02
hyprctl dispatch workspace "$secondary_target"
sleep 0.02

# Final focus should follow the window's rail
if [[ "$rail" == "secondary" ]]; then
  hyprctl dispatch focusmonitor "$SECONDARY"
else
  hyprctl dispatch focusmonitor "$PRIMARY"
fi

# Optional, also refocus the moved window itself
# hyprctl dispatch focuscurrentorlast

#!/usr/bin/env bash
set -euo pipefail

# Acquire lock to serialize rapid scroll events
LOCKFILE="/tmp/wpairswitch.lock"
exec 9>"$LOCKFILE"
flock 9

PRIMARY="DP-1"            # 1..5
SECONDARY="HDMI-A-1"      # 6..10
DIR="${1:-next}"          # next | prev
STATE_FILE="/tmp/wpair_current_ws"

command -v hyprctl >/dev/null

# Read current workspace from state file if fresh, else query compositor
use_cache=0
now=$(date +%s%3N)
if [[ -f "$STATE_FILE" ]]; then
  read -r cached_ws cached_time < "$STATE_FILE" || true
  if [[ -n "$cached_ws" && -n "$cached_time" ]]; then
    if (( now - cached_time < 500 )); then
      use_cache=1
      cur_ws="$cached_ws"
    fi
  fi
fi

if [[ $use_cache -eq 0 ]]; then
  # Query compositor synchronously using jq to avoid focus transition race conditions
  cur_ws=$(hyprctl monitors -j | jq -r --arg m "$PRIMARY" '.[] | select(.name == $m) | .activeWorkspace.id')
fi

[[ "$cur_ws" =~ ^[0-9]+$ ]] || cur_ws=1
base=$(( ((cur_ws-1)%5)+1 ))  # coerce to 1..5 domain

# Step without wrap
if [[ "$DIR" == "next" ]]; then
  if [[ $base -lt 5 ]]; then
    n=$((base + 1))
  else
    n=$base          # at 5, stay on 5
  fi
else
  if [[ $base -gt 1 ]]; then
    n=$((base - 1))
  else
    n=$base          # at 1, stay on 1
  fi
fi
pair=$(( n + 5 ))


# Update state file with workspace and millisecond timestamp
echo "$n $(date +%s%3N)" > "$STATE_FILE"

# Apply all dispatchers atomically via a single hyprctl eval command
hyprctl eval "hl.dispatch(hl.dsp.focus({workspace = \"$n\"})); hl.dispatch(hl.dsp.focus({monitor = \"$SECONDARY\"})); hl.dispatch(hl.dsp.focus({workspace = \"$pair\"})); hl.dispatch(hl.dsp.focus({monitor = \"$PRIMARY\"}))" >/dev/null

# Warp cursor slightly to trigger Wayland motion/hover events on the Waybar overlay
pos=$(hyprctl cursorpos)
x="${pos%%,*}"
y="${pos#*,}"
x="${x//[[:space:]]/}"
y="${y//[[:space:]]/}"
hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $((x + 1)), y = $y })); hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))" >/dev/null


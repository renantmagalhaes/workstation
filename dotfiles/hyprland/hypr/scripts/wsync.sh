#!/usr/bin/env bash
set -euo pipefail

# Configure your monitor names here if needed.
PRIMARY="${PRIMARY_MONITOR:-DP-1}"
SECONDARY="${SECONDARY_MONITOR:-HDMI-A-1}"

# Validate args
if [[ $# -lt 1 ]]; then
  echo "usage: wsync <1-5>"
  exit 1
fi
n="$1"
if ! [[ "$n" =~ ^[1-5]$ ]]; then
  echo "workspace must be 1..5"
  exit 2
fi

# Pair is n+5  ->  1↔6, 2↔7, ... 5↔10
pair=$((n+5))

# Optional sanity check on monitor names
if ! hyprctl monitors | grep -qE "Monitor ${PRIMARY} "; then
  echo "primary monitor ${PRIMARY} not found"
  exit 3
fi
if ! hyprctl monitors | grep -qE "Monitor ${SECONDARY} "; then
  echo "secondary monitor ${SECONDARY} not found"
  exit 4
fi

# Do the switch and update cache
hyprctl eval "hl.dispatch(hl.dsp.focus({monitor = \"${PRIMARY}\"})); hl.dispatch(hl.dsp.focus({workspace = \"${n}\"})); hl.dispatch(hl.dsp.focus({monitor = \"${SECONDARY}\"})); hl.dispatch(hl.dsp.focus({workspace = \"${pair}\"})); hl.dispatch(hl.dsp.focus({monitor = \"${PRIMARY}\"}))" >/dev/null
echo "$n $(date +%s%3N)" > /tmp/wpair_current_ws

# Warp cursor slightly to trigger Wayland motion/hover events on the Waybar overlay
pos=$(hyprctl cursorpos)
x="${pos%%,*}"
y="${pos#*,}"
x="${x//[[:space:]]/}"
y="${y//[[:space:]]/}"
hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $((x + 1)), y = $y })); hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))" >/dev/null


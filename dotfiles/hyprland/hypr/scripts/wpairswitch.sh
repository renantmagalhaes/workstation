#!/usr/bin/env bash
set -euo pipefail

PRIMARY="DP-1"            # 1..5
SECONDARY="HDMI-A-1"      # 6..10
DIR="${1:-next}"          # next | prev

command -v hyprctl >/dev/null

# Base on PRIMARY's current numeric workspace
hyprctl dispatch focusmonitor "$PRIMARY"
cur_ws="$(hyprctl monitors | awk -v M="$PRIMARY" '
  /^Monitor /{gsub(":","",$2); blk=($2==M)}
  blk && /active workspace:/{
    n=$3; gsub(/[()]/,"",n); print n; exit
  }')"

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

# Apply, small sleeps help avoid race
hyprctl dispatch workspace "$n";            sleep 0.02
hyprctl dispatch focusmonitor "$SECONDARY"; sleep 0.02
hyprctl dispatch workspace "$pair";         sleep 0.02
hyprctl dispatch focusmonitor "$PRIMARY"

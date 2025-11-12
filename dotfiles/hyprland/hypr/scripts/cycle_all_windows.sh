#!/usr/bin/env bash
set -euo pipefail

# Direction: next or prev
DIR="${1:-next}"

# Get active workspaces from both monitors
ACTIVE_WS=$(hyprctl monitors -j | jq -r '.[] | .activeWorkspace.id' | sort -u)

# Get all windows from active workspaces
# Format: workspace_id|address|title
WINDOWS=$(hyprctl clients -j | jq -r --arg ws "$ACTIVE_WS" '
  ($ws | split("\n") | map(tonumber)) as $ws_list |
  .[] | 
  select(.workspace.id as $wid | ($ws_list | index($wid) != null)) |
  "\(.workspace.id)|\(.address)|\(.title)"
' | sort -t'|' -k1,1n -k2,2n)

# Get currently focused window address
CURRENT_ADDR=$(hyprctl activewindow -j | jq -r '.address // empty')

if [[ -z "$WINDOWS" ]]; then
    exit 0
fi

# Convert to array
mapfile -t WINDOW_ARRAY < <(echo "$WINDOWS")

# Find current window index
CURRENT_IDX=-1
for i in "${!WINDOW_ARRAY[@]}"; do
    ADDR=$(echo "${WINDOW_ARRAY[$i]}" | cut -d'|' -f2)
    if [[ "$ADDR" == "$CURRENT_ADDR" ]]; then
        CURRENT_IDX=$i
        break
    fi
done

# If current window not found, start from first
if [[ $CURRENT_IDX -eq -1 ]]; then
    CURRENT_IDX=0
fi

# Calculate next/prev index with wrapping
if [[ "$DIR" == "next" ]]; then
    NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#WINDOW_ARRAY[@]} ))
else
    NEXT_IDX=$(( (CURRENT_IDX - 1 + ${#WINDOW_ARRAY[@]}) % ${#WINDOW_ARRAY[@]} ))
fi

# Get the window address to focus
NEXT_ADDR=$(echo "${WINDOW_ARRAY[$NEXT_IDX]}" | cut -d'|' -f2)

# Focus the window
hyprctl dispatch focuswindow "address:$NEXT_ADDR"
hyprctl dispatch bringactivetotop

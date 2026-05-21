#!/usr/bin/env bash
set -euo pipefail

overlay_dir="${1:-}"
monitor_name="${2:-default}"
state_dir="/tmp/hyprlock-overlay"
state_file="$state_dir/${monitor_name}.idx"

if [[ -z "$overlay_dir" ]] || [[ ! -d "$overlay_dir" ]]; then
    exit 1
fi

mkdir -p "$state_dir"

mapfile -t frames < <(
    find "$overlay_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.webp' -o -iname '*.jpg' -o -iname '*.jpeg' \) \
        | sort
)

if [[ ${#frames[@]} -eq 0 ]]; then
    exit 1
fi

idx=0
if [[ -f "$state_file" ]]; then
    idx=$(<"$state_file")
fi

if ! [[ "$idx" =~ ^[0-9]+$ ]]; then
    idx=0
fi

next_idx=$(( (idx + 1) % ${#frames[@]} ))
printf '%s\n' "$next_idx" > "$state_file"
printf '%s\n' "${frames[$idx]}"

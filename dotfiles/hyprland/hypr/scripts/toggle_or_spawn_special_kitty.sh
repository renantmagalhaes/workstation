#!/usr/bin/env bash
set -euo pipefail

SIG="${HYPRLAND_INSTANCE_SIGNATURE:-$(hyprctl -j instances | jq -r '.[0].signature')}"
CMD=(hyprctl --instance "$SIG")

# Helpers
is_on_special() {
  "${CMD[@]}" -j activeworkspace | jq -e '.name=="special:kitty"' >/dev/null
}

has_kitty_in_special() {
  "${CMD[@]}" -j clients | jq -e '.[] | select(.workspace.name=="special:kitty" and .class=="kitty")' >/dev/null
}

if has_kitty_in_special; then
  # Kitty exists already, just toggle visibility
  "${CMD[@]}" dispatch togglespecialworkspace kitty
  exit 0
fi

# No kitty in special
if is_on_special; then
  # We are already on the special workspace, just spawn and focus it
  "${CMD[@]}" dispatch exec '[workspace special:kitty]' kitty
else
  # Not on special, switch to it then spawn focused
  "${CMD[@]}" dispatch workspace special:kitty
  "${CMD[@]}" dispatch exec '[workspace special:kitty]' kitty
fi

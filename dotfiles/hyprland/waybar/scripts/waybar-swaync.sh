#!/usr/bin/env bash
# Minimal swaync indicator script for Waybar
# Outputs an icon based on notification daemon state

set -euo pipefail

STATE=$(swaync-client -D 2>/dev/null || true)
# If do-not-disturb is enabled, show a muted bell; else normal bell
if echo "$STATE" | grep -qi 'Do Not Disturb: true'; then
  printf ""
else
  printf ""
fi

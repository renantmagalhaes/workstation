#!/usr/bin/env bash
# Low mouse battery warning for MangoWM/Wayland with mako notifications
# Same detection as mouse-battery.sh (upower, falling back to solaar),
# but only notifies when the level drops below THRESHOLD.
set -euo pipefail

# Force UTF-8 so notify-send does not choke on strings
export LC_ALL="${LC_ALL:-C.UTF-8}"
export LANG="${LANG:-C.UTF-8}"

THRESHOLD=30

mouse_battery=$(upower --dump 2>/dev/null | grep -iA 5 mouse | grep percentage | grep -oh '[0-9]*' | head -1 || true)

if [ -z "$mouse_battery" ] && command -v solaar >/dev/null 2>&1; then
    mouse_battery=$(solaar show 2>/dev/null | grep -i "Battery:" | grep -oh '[0-9]*%' | head -1 | tr -d '%' || true)
fi

if [ -n "$mouse_battery" ] && [ "$mouse_battery" -lt "$THRESHOLD" ]; then
    notify-send \
        --app-name="Mouse Battery" \
        --icon="battery-low-symbolic" \
        --urgency="critical" \
        --expire-time=8000 \
        "Low Mouse Battery" "🖱️ ${mouse_battery}%" \
        >/dev/null 2>&1 || true
fi

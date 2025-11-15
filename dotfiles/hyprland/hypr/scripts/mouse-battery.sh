#!/usr/bin/env bash
# Mouse battery level checker for Hyprland/Wayland with mako notifications
# Uses upower which works on Wayland, with fallback to solaar for Logitech mice
set -euo pipefail

# Force UTF-8 so notify-send does not choke on strings
export LC_ALL="${LC_ALL:-C.UTF-8}"
export LANG="${LANG:-C.UTF-8}"

# Try to get mouse battery level using upower first
mouse_battery=$(upower --dump 2>/dev/null | grep -iA 5 mouse | grep percentage | grep -oh '[0-9]*' | head -1 || true)

# If upower doesn't work, try solaar (for Logitech mice)
if [ -z "$mouse_battery" ]; then
    if command -v solaar >/dev/null 2>&1; then
        # Extract battery percentage from solaar output
        # Format: "Battery: 50%, BatteryStatus.DISCHARGING."
        mouse_battery=$(solaar show 2>/dev/null | grep -i "Battery:" | grep -oh '[0-9]*%' | head -1 | tr -d '%' || true)
    fi
fi

# Create notification with mako progress bar
if [ -n "$mouse_battery" ]; then
    # Determine icon and urgency based on battery level
    if [ "$mouse_battery" -ge 80 ]; then
        icon="battery-full-symbolic"
        urgency="low"
        status=""
    elif [ "$mouse_battery" -ge 50 ]; then
        icon="battery-good-symbolic"
        urgency="low"
        status=""
    elif [ "$mouse_battery" -ge 20 ]; then
        icon="battery-medium-symbolic"
        urgency="normal"
        status=""
    elif [ "$mouse_battery" -ge 10 ]; then
        icon="battery-low-symbolic"
        urgency="normal"
        status=" (Low)"
    else
        icon="battery-empty-symbolic"
        urgency="critical"
        status=" (Critical!)"
    fi
    
    # Map battery level to mako progress bar (0..100)
    bar_val="$mouse_battery"
    (( bar_val > 100 )) && bar_val=100
    
    title="Mouse Battery"
    body="🖱️ ${mouse_battery}%${status}"
    
    # Send notification with mako progress bar and synchronous tag to replace previous notifications
    notify-send \
        --app-name="Mouse Battery" \
        --icon="$icon" \
        --urgency="$urgency" \
        --expire-time=5000 \
        -h int:value:"$bar_val" \
        -h string:x-canonical-private-synchronous:mouse-battery \
        -h string:synchronous:mouse-battery \
        "$title" "$body" \
        >/dev/null 2>&1 || true
else
    # Notification when battery level not found
    notify-send \
        --app-name="Mouse Battery" \
        --icon="battery-missing-symbolic" \
        --urgency="normal" \
        --expire-time=3000 \
        "Mouse Battery" "🖱️ Mouse battery level not found" \
        >/dev/null 2>&1 || true
fi

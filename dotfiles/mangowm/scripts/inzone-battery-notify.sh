#!/usr/bin/env bash
# Sony INZONE Buds battery level notification for MangoWM/Wayland with mako.
#
# Unlike mouse-battery.sh this cannot query the device: the USB dongle ignores
# polls and only pushes a report every few minutes, so inzone-battery.py --daemon
# (started from startup.conf) catches those and caches them. This just renders
# the cached reading, and says so plainly when there isn't one.
set -euo pipefail

# Force UTF-8 so notify-send does not choke on strings
export LC_ALL="${LC_ALL:-C.UTF-8}"
export LANG="${LANG:-C.UTF-8}"

READER="$HOME/.dotfiles/mangowm/scripts/inzone-battery.py"

notify() {
    notify-send \
        --app-name="INZONE Buds" \
        --icon="$1" \
        --urgency="$2" \
        --expire-time="$3" \
        -h string:x-canonical-private-synchronous:inzone-battery \
        -h string:synchronous:inzone-battery \
        "${@:4}" \
        >/dev/null 2>&1 || true
}

# Exits non-zero when no reading is cached yet or the cached one has gone stale.
reading=""
if [ -x "$READER" ]; then
    reading=$("$READER" --json 2>/dev/null || true)
fi

if [ -z "$reading" ]; then
    notify "battery-missing-symbolic" "normal" "3000" \
        "INZONE Buds" "🎧 No reading - buds off, or listener not running"
    exit 0
fi

slot() { printf '%s' "$reading" | jq -r "if .$1 == null then \"--\" else (.$1|tostring) + \"%\" end"; }

left=$(slot left)
right=$(slot right)
worst=$(printf '%s' "$reading" | jq -r '.percent')

if [ "$worst" -ge 80 ]; then
    icon="battery-full-symbolic"
    urgency="low"
    status=""
elif [ "$worst" -ge 50 ]; then
    icon="battery-good-symbolic"
    urgency="low"
    status=""
elif [ "$worst" -ge 20 ]; then
    icon="battery-medium-symbolic"
    urgency="normal"
    status=""
elif [ "$worst" -ge 10 ]; then
    icon="battery-low-symbolic"
    urgency="normal"
    status=" (Low)"
else
    icon="battery-empty-symbolic"
    urgency="critical"
    status=" (Critical!)"
fi

bar_val="$worst"
((bar_val > 100)) && bar_val=100

notify "$icon" "$urgency" "5000" \
    -h int:value:"$bar_val" \
    "INZONE Buds" "🎧 L ${left}   R ${right}${status}"

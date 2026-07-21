#!/usr/bin/env bash
# Battery watchdog for MangoWM
# Periodically checks mouse battery level and sends a mako notification
# via battery-warning.sh when it drops below the threshold.

set -euo pipefail

CHECK_INTERVAL="${BATTERY_CHECK_INTERVAL:-3600}" # seconds (default: 60 minutes)

while true; do
    "$HOME/.dotfiles/mangowm/scripts/battery-warning.sh" || true
    sleep "$CHECK_INTERVAL"
done

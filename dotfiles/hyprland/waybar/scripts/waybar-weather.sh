#!/usr/bin/env bash
# Simple Waybar weather script using wttr.in
# Prints a short one-line weather string

#export WEATHER_LOCATION="Your City, Country"

set -euo pipefail

# Check if WEATHER_LOCATION environment variable is set
if [ -n "${WEATHER_LOCATION:-}" ]; then
    # Use the specified location (URL encode spaces and special characters)
    location=$(printf '%s\n' "$WEATHER_LOCATION" | sed 's/ /%20/g')
    curl -fsS "https://wttr.in/${location}?format=1" 2>/dev/null || echo ""
else
    # Use default behavior (auto-detect location)
    curl -fsS "https://wttr.in?format=1" 2>/dev/null || echo ""
fi

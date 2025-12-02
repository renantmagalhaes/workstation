#!/usr/bin/env bash
# Simple Waybar weather script using wttr.in
# Prints a short one-line weather string with color based on temperature

#export WEATHER_LOCATION="Your City, Country"

set -euo pipefail

# Check if WEATHER_LOCATION environment variable is set
if [ -n "${WEATHER_LOCATION:-}" ]; then
    # Use the specified location (URL encode spaces and special characters)
    location=$(printf '%s\n' "$WEATHER_LOCATION" | sed 's/ /%20/g')
    weather=$(curl -fsS "https://wttr.in/${location}?format=1&M" 2>/dev/null | sed 's/  */ /g' || echo "")
else
    # Use default behavior (auto-detect location)
    weather=$(curl -fsS "https://wttr.in?format=1&M" 2>/dev/null | sed 's/  */ /g' || echo "")
fi

# Extract temperature (look for number followed by °C or °F or just a number)
temp=$(echo "$weather" | grep -oE '[0-9]+' | head -1)

# Check if temperature is greater than 20
if [ -n "$temp" ] && [ "$temp" -gt 30 ]; then
    # Wrap in red span if temp > 20 (using Pango markup)
    echo "<span foreground='#fc285a'>$weather</span>"
else
    # Output normally if temp <= 20
    echo "$weather"
fi

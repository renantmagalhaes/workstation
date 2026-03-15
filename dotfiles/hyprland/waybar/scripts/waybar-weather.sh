#!/usr/bin/env bash
# Simple Waybar weather script using wttr.in
# Prints a short one-line weather string with color based on temperature

#export WEATHER_LOCATION="Your City, Country"

set -euo pipefail

# Check if WEATHER_LOCATION environment variable is set
if [ -n "${WEATHER_LOCATION:-}" ]; then
    # Use the specified location (URL encode spaces and special characters)
    location=$(printf '%s\n' "$WEATHER_LOCATION" | sed 's/ /%20/g')
else
    location=""
fi

# Fetch short weather for the bar
weather=$(curl -fsS "https://wttr.in/${location}?format=1&M" 2>/dev/null | sed 's/  */ /g' || echo "")

# Fetch detailed weather for the tooltip
# %l: location, %c: condition icon, %t: temperature, %C: condition, %w: wind, %h: humidity, %P: pressure, %p: precipitation, %o: visibility
tooltip_raw=$(curl -fsS "https://wttr.in/${location}?format=%l\n%c+%t\nCondition:+%C\nWind:+%w\nHumidity:+%h\nPressure:+%P\nPrecipitation:+%p" 2>/dev/null || echo "Weather data unavailable")

# Extract temperature for color logic
temp=$(echo "$weather" | grep -oE '[0-9]+' | head -1)

# Format the weather string for display
if [ -n "$temp" ] && [ "$temp" -gt 30 ]; then
    display_text="<span foreground='#fc285a'>$weather</span>"
else
    display_text="$weather"
fi

# Format tooltip with Pango markup
# We use newline characters which jq will escape to \n for JSON
# Extract location from the first line of tooltip_raw
loc_name=$(echo "$tooltip_raw" | head -n 1)
weather_info=$(echo "$tooltip_raw" | tail -n +2)

TOOLTIP=$(printf "<span size='large' color='#89b4fa'><b>Weather in %s</b></span>\n\n" "$loc_name")
# Replace newlines and format labels
TOOLTIP_CONTENT=$(echo "$weather_info" | sed 's/Condition:/<span color="#fab387"><b>Condition:<\/b><\/span>/g; s/Wind:/<span color="#f38ba8"><b>Wind:<\/b><\/span>/g; s/Humidity:/<span color="#a6e3a1"><b>Humidity:<\/b><\/span>/g; s/Pressure:/<span color="#94e2d5"><b>Pressure:<\/b><\/span>/g; s/Precipitation:/<span color="#89dceb"><b>Precipitation:<\/b><\/span>/g')
TOOLTIP+="$TOOLTIP_CONTENT"

# Format as JSON string using jq for safe escaping
# -c produces compact output (single line), which is more reliable for Waybar
jq -nc --arg text "$display_text" --arg tooltip "$TOOLTIP" '{text: $text, tooltip: $tooltip}'

#!/usr/bin/env bash
# Emit one compact JSON line of current weather for the QuickShell island.
# Reduces wttr.in's ~30KB j1 payload to just what the bar shows.
# Honours WEATHER_LOCATION like waybar/scripts/waybar-weather.sh did; unset
# means wttr.in geolocates by IP.
set -uo pipefail

location="${WEATHER_LOCATION:-}"
url="https://wttr.in/${location// /%20}?format=j1"

raw=$(curl -fsS --max-time 15 "$url" 2>/dev/null) || raw=""

if [ -z "$raw" ]; then
  echo '{"ok":false}'
  exit 0
fi

echo "$raw" | jq -c --arg configured "$location" '
  (.current_condition[0]) as $c |
  {
    ok: true,
    # What the user asked for, if anything. wttr.in reports the nearest named
    # locality, which for a rural request is some neighbouring hamlet nobody
    # recognises -- so prefer this for display.
    configured: $configured,
    tempC:    ($c.temp_C        | tonumber? // null),
    feelsC:   ($c.FeelsLikeC    | tonumber? // null),
    humidity: ($c.humidity      | tonumber? // null),
    windKmph: ($c.windspeedKmph | tonumber? // null),
    code:     ($c.weatherCode   | tonumber? // null),
    desc:     ($c.weatherDesc[0].value // ""),
    location: ([ .nearest_area[0].areaName[0].value,
                 .nearest_area[0].country[0].value ] | map(select(. != null and . != "")) | join(", "))
  }' 2>/dev/null || echo '{"ok":false}'

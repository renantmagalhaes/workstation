#!/usr/bin/env bash
# Emit rich JSON of current weather and 3-day forecast for the QuickShell island.
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
  (.weather[0]) as $today |
  {
    ok: true,
    configured: $configured,
    tempC:    ($c.temp_C        | tonumber? // null),
    feelsC:   ($c.FeelsLikeC    | tonumber? // null),
    humidity: ($c.humidity      | tonumber? // null),
    windKmph: ($c.windspeedKmph | tonumber? // null),
    code:     ($c.weatherCode   | tonumber? // null),
    desc:     ($c.weatherDesc[0].value // ""),
    location: ([ .nearest_area[0].areaName[0].value,
                 .nearest_area[0].country[0].value ] | map(select(. != null and . != "")) | join(", ")),
    sunrise:      ($today.astronomy[0].sunrise // ""),
    sunset:       ($today.astronomy[0].sunset  // ""),
    minC:         ($today.mintempC | tonumber? // null),
    maxC:         ($today.maxtempC | tonumber? // null),
    chanceOfRain: ($today.hourly[0].chanceofrain | tonumber? // 0),
    forecast: [ .weather[] | {
      date: .date,
      minC: (.mintempC | tonumber? // null),
      maxC: (.maxtempC | tonumber? // null),
      code: (.hourly[4].weatherCode | tonumber? // null),
      desc: (.hourly[4].weatherDesc[0].value // ""),
      rain: (.hourly[4].chanceofrain | tonumber? // 0)
    } ]
  }' 2>/dev/null || echo '{"ok":false}'

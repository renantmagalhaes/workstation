#!/usr/bin/env bash
# Volume change with single replacing mako progress notification
# Supports PulseAudio or PipeWire, shows 0..100 bar, allows up to 150%
set -euo pipefail

# Force UTF-8 so notify-send does not choke on strings
export LC_ALL="${LC_ALL:-C.UTF-8}"
export LANG="${LANG:-C.UTF-8}"

STEP="${1:-+5}"                                # +5, -5, or "toggle"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
IDFILE="$CACHE_DIR/vol-notify.id"              # not used for replace, kept for debugging
TSFILE="$CACHE_DIR/vol-notify.last"            # timestamp for coalescing
LOCK="/tmp/volnotify.lock"                     # serialization lock
mkdir -p "$CACHE_DIR"

have_pamixer=false
command -v pamixer >/dev/null 2>&1 && have_pamixer=true

clamp() {
  local v="$1" min="$2" max="$3"
  (( v < min )) && v="$min"
  (( v > max )) && v="$max"
  printf '%s' "$v"
}

# 1) Change volume
if [[ "$STEP" == "toggle" ]]; then
  if $have_pamixer; then
    pamixer -t
  else
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  fi
else
  # normalize signed step
  local_sign="+"
  [[ "$STEP" == -* ]] && local_sign="-"
  amt="${STEP#[+-]}"
  [[ -z "$amt" ]] && amt=5

  if $have_pamixer; then
    cur="$(pamixer --get-volume)"
    if [[ "$local_sign" == "+" ]]; then new=$(( cur + amt )); else new=$(( cur - amt )); fi
    new="$(clamp "$new" 0 150)"
    pamixer --set-volume "$new" --allow-boost
  else
    # PipeWire path, set absolute 0.00 to 1.50
    line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"     # "Volume: 0.57 [MUTED]" or "Volume: 1.23"
    curp="$(awk '{print int($2*100 + 0.5)}' <<<"$line")"
    if [[ "$local_sign" == "+" ]]; then new=$(( curp + amt )); else new=$(( curp - amt )); fi
    new="$(clamp "$new" 0 150)"
    newf="$(awk -v p="$new" 'BEGIN{printf("%.3f", p/100.0)}')"
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$newf"
  fi
fi

# 2) Coalesce very rapid repeats, drop if last notify was < 60 ms ago
now_ms="$(date +%s%3N)"
last_ms="$(cat "$TSFILE" 2>/dev/null || echo 0)"
if (( now_ms - last_ms < 60 )); then
  exit 0
fi
printf '%s' "$now_ms" > "$TSFILE"

# 3) Read current volume and mute state
if $have_pamixer; then
  vol="$(pamixer --get-volume)"
  if pamixer --get-mute | grep -q true; then muted=true; else muted=false; fi
else
  line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
  vol="$(awk '{print int($2*100 + 0.5)}' <<<"$line")"
  if grep -q MUTED <<<"$line"; then muted=true; else muted=false; fi
fi
vol="$(clamp "$vol" 0 150)"

# 4) Choose icon
icon="audio-volume-medium-symbolic"
if [[ "$muted" == true || "$vol" -eq 0 ]]; then
  icon="audio-volume-muted-symbolic"
elif (( vol <= 30 )); then
  icon="audio-volume-low-symbolic"
elif (( vol >= 90 )); then
  icon="audio-volume-high-symbolic"
fi

# 5) Map to mako progress 0..100
bar_val="$vol"
(( bar_val > 100 )) && bar_val=100

title="Volume"
[[ "$muted" == true ]] && title="Volume (muted)"
body="$(printf "%3d%%" "$vol")"

# 6) Serialize notify-send so replacements cannot race
exec 9>"$LOCK"
if ! flock -n 9; then
  exit 0
fi

# 7) Single merged notification using synchronous tag, no duplicate bars
notify-send \
  --app-name="Volume" \
  --icon="$icon" \
  --urgency=low \
  --expire-time=1200 \
  -h int:value:"$bar_val" \
  -h string:x-canonical-private-synchronous:volume \
  -h string:synchronous:volume \
  "$title" "$body" \
  >/dev/null 2>&1 || true

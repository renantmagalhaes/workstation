#!/usr/bin/env sh
# Opens the QS-Launcher spotlight popup and clicks its search box so mango
# actually hands it keyboard focus.
#
# mango only grants click-to-focus for "on-demand" layer-shell surfaces, not
# "exclusive" ones (see handle_buttonpress in mango's src/mango.c), and its
# exclusive-focus grant on map doesn't reliably fire for this launcher. A
# real pointer click inside the surface works around both. Always "show"
# (never toggle) so we never click a launcher that's mid-close - dismiss it
# with Escape or by clicking outside it instead.
#
# wlrctl's pointer move is relative, not absolute, so we read the current
# cursor position and compute the delta to the launcher's monitor center
# (where the modal always centers itself).
#
# Deliberately NOT moving the cursor back afterwards: mango has
# sloppyfocus=1 (focus-follows-mouse), and moving the pointer back over
# whatever window it started on hands keyboard focus straight back there,
# undoing the click above.
set -eu

MAIN_QML="$HOME/.QS-Launcher/launcher.qml"

if ! quickshell ipc --path "$MAIN_QML" call launcher show >/dev/null 2>&1; then
    SPOTLIGHT_START_HIDDEN=1 quickshell -d -n -p "$MAIN_QML" >/dev/null 2>&1 &
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        if quickshell ipc --path "$MAIN_QML" call launcher show >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
fi

sleep 0.3

MONITOR=$(mmsg get all-monitors | jq -r '.monitors[] | select(.last_open_surface=="spotlight:launcher") | .name' | head -n1)
[ -z "$MONITOR" ] && exit 0

GEOM=$(mmsg get monitor "$MONITOR")
MX=$(printf '%s' "$GEOM" | jq -r '.x')
MY=$(printf '%s' "$GEOM" | jq -r '.y')
MW=$(printf '%s' "$GEOM" | jq -r '.width')
MH=$(printf '%s' "$GEOM" | jq -r '.height')
TARGET_X=$(awk "BEGIN { print $MX + $MW / 2 }")
TARGET_Y=$(awk "BEGIN { print $MY + $MH / 2 }")

POS=$(mmsg get cursorpos)
ORIG_X=$(printf '%s' "$POS" | jq -r '.x')
ORIG_Y=$(printf '%s' "$POS" | jq -r '.y')

DX=$(awk "BEGIN { print $TARGET_X - $ORIG_X }")
DY=$(awk "BEGIN { print $TARGET_Y - $ORIG_Y }")

wlrctl pointer move "$DX" "$DY"
wlrctl pointer click left
# Click twice with a gap: mango needs to actually process quickshell's
# keyboard-interactivity=on-demand protocol commit before a click will grab
# focus, and that can lose the race against a single click under load. A
# second click a beat later is cheap insurance - it's a no-op if the first
# one already worked.
sleep 0.15
wlrctl pointer click left

#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar main &
sleep 1
polybar secondary &


echo "Bars launched..."

# # if in kde, this will display tray icons
# pidof xembedsniproxy |xargs kill -9


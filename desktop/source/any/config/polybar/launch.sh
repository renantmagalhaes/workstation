#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar main >>~/polybar.log 2>&1 &
sleep 1
polybar secondary >>~/polybar.log 2>&1 &



echo "Bars launched..."

# # if in kde, this will display tray icons
# pidof xembedsniproxy |xargs kill -9


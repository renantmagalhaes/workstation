#!/usr/bin/env bash

# Terminate already running bar instances
pidof polybar | xargs kill -9

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar main-scroll >>~/polybar-scroll.log 2>&1 &
polybar main-scroll-bottom >>~/polybar-scroll.log 2>&1 &
sleep 2
polybar secondary-scroll >>~/polybar-scroll.log 2>&1 &
polybar secondary-scroll-bottom >>~/polybar-scroll.log 2>&1 &

echo "Bars launched..."

# # if in kde, this will display tray icons
# pidof xembedsniproxy |xargs kill -9

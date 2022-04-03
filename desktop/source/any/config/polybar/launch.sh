#!/usr/bin/env bash

# dir="$HOME/.config/polybar"
# themes=(`ls --hide="launch.sh" $dir`)

# launch_bar() {
# 	# Terminate already running bar instances
# 	killall -q polybar

# 	# Wait until the processes have been shut down
# 	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# 	# Launch the bar
# 	polybar -q main -c "$dir/$style/config.ini" &
#     sleep 1
#     polybar -q secondary -c "$dir/$style/config.ini" &
# }


# style="panels"
# launch_bar


#

# if in kde, this will display tray icons
pidof xembedsniproxy |xargs kill -9


# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bars
polybar main &
sleep 1
polybar secondary &


echo "Bars launched..."




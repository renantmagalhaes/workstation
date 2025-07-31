#!/bin/bash

while true; do
	kitty_windows=$(xdotool search --onlyvisible --class kitty)
	for win in $kitty_windows; do
		xprop -id "$win" -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0
	done
	sleep 1
done

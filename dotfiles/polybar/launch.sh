#!/usr/bin/env bash

# Function to start bars
start_bars() {
	# Terminate already running bar instances
	pidof polybar | xargs kill -9

	# Wait until the processes have been shut down
	while pgrep -x polybar >/dev/null; do sleep 1; done

	# Launch bars
	sleep 1
	polybar main >>~/polybar.log 2>&1 &
	polybar main-scroll >>~/polybar-scroll.log 2>&1 &
	polybar main-scroll-bottom >>~/polybar-scroll.log 2>&1 &
	sleep 1
	polybar secondary >>~/polybar.log 2>&1 &
	polybar secondary-scroll >>~/polybar-scroll.log 2>&1 &
	polybar secondary-scroll-bottom >>~/polybar-scroll.log 2>&1 &

	echo "Bars launched..."
}

# Start the bars initially
start_bars

# Monitor bars
while true; do
	sleep 10
	# Check and restart individual bars if necessary
	if ! pgrep -fx "polybar main-scroll" >/dev/null; then
		echo "Restarting main-scroll..."
		polybar main-scroll >>~/polybar-scroll.log 2>&1 &
	fi
	if ! pgrep -fx "polybar main-scroll-bottom" >/dev/null; then
		echo "Restarting main-scroll-bottom..."
		polybar main-scroll-bottom >>~/polybar-scroll.log 2>&1 &
	fi
	if ! pgrep -fx "polybar main" >/dev/null; then
		echo "Restarting main..."
		polybar main >>~/polybar.log 2>&1 &
	fi
	if ! pgrep -fx "polybar secondary" >/dev/null; then
		echo "Restarting secondary..."
		polybar secondary >>~/polybar.log 2>&1 &
	fi
	if ! pgrep -fx "polybar secondary-scroll" >/dev/null; then
		echo "Restarting secondary-scroll..."
		polybar secondary-scroll >>~/polybar-scroll.log 2>&1 &
	fi
	if ! pgrep -fx "polybar secondary-scroll-bottom" >/dev/null; then
		echo "Restarting secondary-scroll-bottom..."
		polybar secondary-scroll-bottom >>~/polybar-scroll.log 2>&1 &
	fi
done

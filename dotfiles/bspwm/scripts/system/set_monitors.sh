#!/bin/bash

# Declare arrays to hold monitor names
PRIMARY_MONITORS=()
SECONDARY_MONITORS=()

# Get connected monitors
MONITORS=$(xrandr | grep ' connected' | awk '{ print $1 }')

# Loop through connected monitors and categorize them
for MONITOR in $MONITORS; do
	case $MONITOR in
	DP-2 | HDMI-2)
		PRIMARY_MONITORS+=("$MONITOR")
		;;
	HDMI-2 | DP-0)
		SECONDARY_MONITORS+=("$MONITOR")
		;;
	esac
done

# Export arrays as environment variables (optional)
export PRIMARY_MONITORS
export SECONDARY_MONITORS

# Optionally, print them for verification
echo "Primary Monitors: ${PRIMARY_MONITORS[*]}"
echo "Secondary Monitors: ${SECONDARY_MONITORS[*]}"

#!/bin/bash

# Detect connected DP and HDMI monitors
DP_MONITOR=$(xrandr --listactivemonitors | grep -E 'DisplayPort|DP' | awk '{print $4}')
HDMI_MONITOR=$(xrandr --listactivemonitors | grep -E 'HDMI' | awk '{print $4}')

# The file where we'll store the monitor variables
PROFILE_FILE="$HOME/.zprofile"

# Function to check if the variable is already in the profile and if it needs updating
update_profile() {
	local variable_name=$1
	local variable_value=$2
	if ! grep -q "$variable_name" "$PROFILE_FILE"; then
		# If the variable doesn't exist, add it to the profile
		echo "export $variable_name=\"$variable_value\"" >>"$PROFILE_FILE"
	else
		# If the variable exists, update it only if the value is different
		current_value=$(grep "$variable_name" "$PROFILE_FILE" | cut -d '=' -f2 | tr -d '"')
		if [ "$current_value" != "$variable_value" ]; then
			# Replace the old value with the new one
			sed -i "s|$variable_name=\"$current_value\"|$variable_name=\"$variable_value\"|" "$PROFILE_FILE"
		fi
	fi
}

# Update the .zprofile with the monitor variables if needed
update_profile "MONITOR_DP" "$DP_MONITOR"
update_profile "MONITOR_HDMI" "$HDMI_MONITOR"

# Print out the detected monitors (for debugging purposes)
echo "Detected DP Monitor: $DP_MONITOR"
echo "Detected HDMI Monitor: $HDMI_MONITOR"

# Now export the variables in the current session
export MONITOR_DP=$DP_MONITOR
export MONITOR_HDMI=$HDMI_MONITOR

# Optionally, you can run your setup code here (e.g., bspwm or other monitor setup)
# bspc monitor $MONITOR_DP -d 1 2 3 4 5
# bspc monitor $MONITOR_HDMI -d 11 22 33 44 55

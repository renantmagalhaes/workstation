#!/bin/bash

# Windscribe‑CLI + WireGuard VPN status check

CACHE_FILE="/tmp/windscribe-last-location"
uid="$(id -u)"

# tmux can start before the graphical session has exported its runtime env.
# Rebuild the minimum DBus/runtime vars Windscribe expects so status checks
# keep working after tmux is already running.
export HOME="${HOME:-$(getent passwd "$uid" | cut -d: -f6)}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$uid}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

if ! command -v windscribe-cli &>/dev/null; then
	echo "#[fg=#ff4237][󰒄 VPN Disconnected] #[fg=white]"
	exit 0
fi

# Grab the full status output (silence errors if windscribe‑cli isn't installed)
# Use timeout to prevent tmux from freezing if the daemon hangs
status=$(timeout 1 windscribe-cli status 2>/dev/null)
exit_code=$?

# Extract the "Connect state:" field (e.g. ""Disconnected")
# Use ^ to anchor to start of line to avoid matching JSON output
connectState=$(echo "$status" | sed -n -e 's/^Connect state: \(.*\)/\1/p')

# If timeout or empty state, daemon might be disconnected/busy
if [[ $exit_code -eq 124 ]] || [[ -z "$connectState" ]]; then
	# Detect any active WireGuard/tun interface used by VPN
	fallback_iface=$(ls /sys/class/net 2>/dev/null | grep -E '^(wg|utun|windscribe)' | head -n1)
	if [[ -n $fallback_iface ]]; then
		# If we have a cached location from before the daemon hung, use it
		if [[ -f "$CACHE_FILE" ]]; then
			location=$(cat "$CACHE_FILE")
			echo "#[fg=#7feaac][󰒄 $location] #[fg=white]"
		else
			echo "#[fg=#7feaac][󰒄 VPN Connected] #[fg=white]"
		fi
	else
		if [[ $exit_code -eq 124 ]]; then
			echo "#[fg=#fef65b][󰒄 VPN Timeout] #[fg=white]"
		else
			echo "#[fg=#ff4237][󰒄 VPN Disconnected] #[fg=white]"
		fi
	fi
	exit 0
fi

if [[ $connectState == Connected:* ]]; then
	# Strip the leading "Connected: " to get just the location
	location=${connectState#Connected: }
	# Keep only the first place before " - " and capitalize first letter
	location=${location%% - *}
	location=${location^}

	# Cache the location for fallback scenarios
	echo "$location" > "$CACHE_FILE"

	#echo "- #[fg=#7feaac][󰒄 VPN Connected: $location] #[fg=white]"
	echo "#[fg=#7feaac][󰒄 $location] #[fg=white]"
elif [[ $connectState == Disconnected ]]; then
	# Treat as disconnected if Windscribe reports disconnected
	# Clean up cache when disconnected
	rm -f "$CACHE_FILE"
	echo "#[fg=#ff4237][󰒄 VPN Disconnected] #[fg=white]"
else
	# Anything else (e.g. in‑between states) treat as "connecting"
	echo "#[fg=#fef65b]󰒄 VPN Connecting #[fg=white]"
fi

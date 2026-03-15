#!/bin/bash

# NordVPN status check

CACHE_FILE="/tmp/nordvpn-last-location"

if ! command -v nordvpn &>/dev/null; then
	echo "#[fg=#ff4237]󰒄 VPN Disconnected #[fg=white]"
	exit 0
fi

# Use timeout to prevent tmux from freezing if the daemon hangs
status_output=$(timeout 1 nordvpn status 2>/dev/null)
exit_code=$?

nordStatus=$(echo "$status_output" | sed -n -e 's/Status: \(.*\)/\1/p' | tr -d '\r')

# If timeout or empty state, daemon might be disconnected/busy
if [[ $exit_code -eq 124 ]] || [[ -z "$nordStatus" ]]; then
	# Detect any active VPN interface (Nordlynx, WireGuard, Tun)
	fallback_iface=$(ls /sys/class/net 2>/dev/null | grep -E '^(nordlynx|wireguard|wg|tun)' | head -n1)
	if [[ -n $fallback_iface ]]; then
		# If we have a cached location from before the daemon hung, use it
		if [[ -f "$CACHE_FILE" ]]; then
			location=$(cat "$CACHE_FILE")
			echo "#[fg=#7feaac]󰒄 $location #[fg=white]"
		else
			echo "#[fg=#7feaac]󰒄 VPN Connected #[fg=white]"
		fi
	else
		if [[ $exit_code -eq 124 ]]; then
			echo "#[fg=#fef65b]󰒄 VPN Timeout #[fg=white]"
		else
			echo "#[fg=#ff4237]󰒄 VPN Disconnected #[fg=white]"
		fi
	fi
	exit 0
fi

if [[ $nordStatus == *"Connected"* ]]; then
	nordCountry=$(echo "$status_output" | sed -n -e 's/Country: \(.*\)/\1/p' | tr -d '\r')
	nordCity=$(echo "$status_output" | sed -n -e 's/City: \(.*\)/\1/p' | tr -d '\r')
	
	location="$nordCountry"
	if [[ -n "$nordCity" ]]; then
		location="$nordCity, $nordCountry"
	fi

	# Cache the location for fallback scenarios
	echo "$location" > "$CACHE_FILE"
	
	echo "#[fg=#7feaac]󰒄 $location #[fg=white]"
elif [[ $nordStatus == *"Connecting"* ]]; then
	echo "#[fg=#fef65b]󰒄 VPN Connecting #[fg=white]"
else
	# Ensure cache is forgotten when intentionally disconnected
	rm -f "$CACHE_FILE"
	echo "#[fg=#ff4237]󰒄 VPN Disconnected #[fg=white]"
fi

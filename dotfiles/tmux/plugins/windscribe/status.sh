#!/bin/bash

# Windscribe‑CLI + WireGuard VPN status check

# Grab the full status output (silence errors if windscribe‑cli isn’t installed)
status=$(windscribe-cli status 2>/dev/null)

# Extract the “Connect state:” field (e.g. “Connected: Lisbon - Bairro” or “Disconnected”)
connectState=$(echo "$status" | sed -n -e 's/Connect state: \(.*\)/\1/p')

# Optionally: detect any active WireGuard interface
wgInterface=$(ls /sys/class/net | grep -E '^wireguard' | head -n1)

if [[ $connectState == Connected:* ]]; then
	# Strip the leading “Connected: ” to get just the location
	location=${connectState#Connected: }
	echo "#[fg=#7feaac]󰒄 VPN Connected #[fg=white]"
elif [[ -n $wgInterface ]]; then
	# If Windscribe itself isn’t connected but a WireGuard iface exists
	echo "#[fg=#7feaac]󰒄 VPN Connected [WireGuard: $wgInterface] #[fg=white]"
elif [[ $connectState == Disconnected ]] || ! command -v windscribe-cli &>/dev/null; then
	# Treat as disconnected if either Windscribe reports disconnected or the CLI isn’t installed
	echo "#[fg=#ff4237]󰒄 VPN Disconnected #[fg=white]"
else
	# Anything else (e.g. in‑between states) treat as “connecting”
	echo "#[fg=#fef65b]󰒄 VPN Connecting #[fg=white]"
fi

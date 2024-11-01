#!/bin/bash

# NordVPN status check
nordStatus=$(nordvpn status | sed -n -e 's/Status: \(.*\)/\1/p')

# Check for any active WireGuard interfaces
wgInterface=$(ls /sys/class/net | grep -E '^wireguard' | head -n 1)

# Determine combined VPN status
if [[ $nordStatus == *"Connected"* || -n $wgInterface ]]; then
	# If either NordVPN or WireGuard is connected
	if [[ $nordStatus == *"Connected"* ]]; then
		nordCountry=$(nordvpn status | sed -n -e 's/Country: \(.*\)/\1/p')
		echo "#[fg=#7feaac]󰒄 VPN Connected [NordVPN: $nordCountry] #[fg=white]"
	else
		echo "#[fg=#7feaac]󰒄 VPN Connected [WireGuard] #[fg=white]"
	fi
elif [[ $nordStatus == *"Connecting"* ]]; then
	# If NordVPN is connecting (WireGuard does not have a "connecting" state)
	echo "#[fg=#fef65b]󰒄 VPN Connecting #[fg=white]"
else
	# If neither is connected
	echo "#[fg=#ff4237]󰒄 VPN Disconnected #[fg=white]"
fi

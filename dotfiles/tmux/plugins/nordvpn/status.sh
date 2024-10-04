#!/bin/bash

#if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]] ; then echo "#[fg=red]VPN Disconnected:" ; else echo "#[fg=blue]VPN Connected:" ; fi

nordStatus=$(nordvpn status | sed -n -e 's/Status: \(.*\)/\1/p')
nordCountry=$(nordvpn status | sed -n -e 's/Country: \(.*\)/\1/p')

if [[ $nordStatus == *"Disconnected"* ]]; then
	echo "#[fg=#ff4237]󰒄 Disconnected #[fg=white]"
elif [[ $nordStatus == *"Connected"* ]]; then
	echo "#[fg=#7feaac]󰒄 Connected [$nordCountry] #[fg=white]"
elif [[ $nordStatus == *"Connecting"* ]]; then
	echo "#[fg=#fef65b]󰒄 Connecting"
else
	echo "#[fg=#000000]󰒃 #[fg=white]"
fi

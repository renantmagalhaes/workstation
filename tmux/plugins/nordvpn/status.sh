#!/bin/bash

#if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]] ; then echo "#[fg=red]VPN Disconnected:" ; else echo "#[fg=blue]VPN Connected:" ; fi

nordStatus=`nordvpn status | sed -n -e 's/Status: \(.*\)/\1/p'`
nordCountry=`nordvpn status | sed -n -e 's/Country: \(.*\)/\1/p'`


if [[ $nordStatus == *"Disconnected"* ]]
then
    echo "#[fg=red]VPN Disconnected #[fg=white]|"
elif [[ $nordStatus == *"Connected"* ]]
then
    echo "#[fg=green]VPN Connected [$nordCountry] #[fg=white]|"
elif [[ $nordStatus == *"Connecting"* ]]
then
    echo "#[fg=yellow]VPN Connecting |"
else
    echo "NordVPN not found |"
fi
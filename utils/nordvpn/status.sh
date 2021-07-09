#!/bin/bash

#if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]] ; then echo "#[fg=red]VPN Disconnected:" ; else echo "#[fg=blue]VPN Connected:" ; fi


if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]]
then 
    echo "#[fg=red]VPN Disconnected:"
elif [[ `nordvpn status |grep Status |awk '{print $4}'` == "Connected" ]]
then
    echo "#[fg=blue]VPN Connected:"
elif [[ `nordvpn status |grep Status |awk '{print $4}'` == "Connecting" ]]
then
    echo "#[fg=yellow]VPN Connecting"
else
    echo "Nordvpn not installed"
fi
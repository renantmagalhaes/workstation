#!/bin/bash

#if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]] ; then echo "#[fg=red]VPN Disconnected:" ; else echo "#[fg=blue]VPN Connected:" ; fi

nordStatus_apt=`nordvpn status |grep Status |awk '{print $3}'`
nordStatus_dnf=`nordvpn status |grep Status |awk '{print $6}'`
nordCountry=`nordvpn status |grep Country: |awk '{print $2}'`



if [[ $nordStatus_apt == "Disconnected" ]] || [[ $nordStatus_dnf == "Disconnected" ]]
then
    echo "#[fg=red]VPN Disconnected #[fg=white]|"
elif [[ $nordStatus_apt == "Connected" ]] || [[ $nordStatus_dnf == "Connected" ]]
then
    echo "#[fg=green]VPN Connected [$nordCountry] #[fg=white]|"
elif [[ $nordStatus_apt == "Connecting" ]] || [[ $nordStatus_dnf == "Connecting" ]]
then
    echo "#[fg=yellow]VPN Connecting |"
else
    echo "NordVPN not found |"
fi
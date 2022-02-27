#!/bin/bash

#if [[ `nordvpn status |grep Status |awk '{print $4}'` == "Disconnected" ]] ; then echo "#[fg=red]VPN Disconnected:" ; else echo "#[fg=blue]VPN Connected:" ; fi

# avail_memory=`free -m |grep Mem |awk '{print $7}'`
# num=1024
# ans$((avail_memory / num))

# echo ans

avai_mem_m=`free -m |grep Mem |awk '{print $7}'`
converter_to_gb=1024

avai_mem_gb=$((avai_mem_m / converter_to_gb))G

echo "#[fg=#5F8787]  $avai_mem_gb"

# if [[ $current >= "10" ]]
# then 
#     echo "#[fg=green]$current"
# # elif [[ $current_memory >= "30" ]]
# # then
# #     echo "#[fg=green]VPN Connected [$nordCountry] #[fg=white]|"
# # elif [[ $current_memory >= "70" ]]
# # then
# #     echo "#[fg=yellow]VPN Connecting |"
# else
#     echo "Error, please contact suport |"
# fi

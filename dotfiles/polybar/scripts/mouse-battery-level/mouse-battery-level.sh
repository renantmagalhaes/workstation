#!/bin/bash

CURRENT_BATTERY_LEVEL=`upower --dump |grep -iA 5 mouse |grep percentage |egrep -oh '[0-9]*'`

if [ $CURRENT_BATTERY_LEVEL -ge 20 ]
then
    echo %{F#65ff5e} $CURRENT_BATTERY_LEVEL%%{F-}

elif [ $CURRENT_BATTERY_LEVEL -ge 10 ]
then
    echo %{F#feff25} $CURRENT_BATTERY_LEVEL%%{F-}

else
    echo %{F#f02} $CURRENT_BATTERY_LEVEL%%{F-}
fi
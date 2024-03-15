#!/bin/bash

Red=$'\e[1;31m'

IS_ACTIVE=`pactl list | sed -n '/^Source/,/^$/p' | grep Mute |sort |uniq |grep yes`



if [ $? -eq 0 ]; then
   echo %{F#f02}%{F-}
else
   echo ""
fi

# if [ $? -eq 0 ]; then
#    echo "$Red"
# else
#    echo "$Red"
# fi
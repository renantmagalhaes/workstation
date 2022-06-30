#!/bin/bash

# credits to https://askubuntu.com/a/1335962

#check if monitor number was given
if test -z "$1" 
then
  #no monitor number was given, use the main display
  MON_NO=0
else
  MON_NO=$1
fi


#get connection of monitor with number $MON_NO
MON_CON=$(xrandr --listactivemonitors | grep "$MON_NO:" | tr -s " " | cut -d " " -f 5)

#check if monitors id could be found
if test -z "$MON_CON"
then
  #no monitor with given number found!
  echo "no monitor with number $MON_NO was found!"
  MON_COUNT=$(xrandr --listactivemonitors | grep "Monitors:" | cut -d " " -f 2)
  echo "(A total of $MON_COUNT monitors were found.)"
  exit -1
fi

#for each id of wacom devices set correct output monitor
xsetwacom list devices |
while IFS= read -r line; do
  #get id of wacom device in line
  WACOM_ID="$(echo $line | sed 's/.*id: //' | cut -d " " -f 1)"
  #set monitor as output
  xsetwacom --set $WACOM_ID MapToOutput $MON_CON
done

echo "Changed monitor for all wacom devices."
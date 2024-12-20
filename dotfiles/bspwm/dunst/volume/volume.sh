#!/bin/bash

action=$1
rightVol=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $12}' | tr -dc '0-9')
leftVol=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -dc '0-9')
muteOrNot=$(pactl get-sink-mute @DEFAULT_SINK@ | awk -F: '{ print $2 }')
inc=5

if [ $action = 'up' ]; then
		if [[ $rightVol -ge 175 ]]; then
		exit
		fi
	pactl set-sink-volume @DEFAULT_SINK@ +$inc%
  	if [ $muteOrNot = 'no' ]; then
  		dunstify "$(expr $rightVol + $inc)" -i audio-volume-high  -u low -t 1000 -r 9993 -h int:value:$rightVol
  	elif [$muteOrNot = 'yes' ]; then
		dunstify "$(expr $rightVol + $inc)" -i mute -u low -t 1000 -r 9993 -h int:value:$rightVol
	fi
elif [ $action = 'down' ]; then
	pactl set-sink-volume @DEFAULT_SINK@ -$inc%
	if [ $rightVol = 0 ]; then
	if [ $muteOrNot = 'no' ]; then
		dunstify "0" -i audio-volume-medium -u mute -t 1000 -r 9993 -h int:value:0
	elif [$muteOrNot = 'yes' ]; then
		dunstify "0" -i audio-volume-high  -u mute -t 1000 -r 9993 -h int:value:0
	fi
	elif [ $muteOrNot = 'no' ]; then
		dunstify "$(expr $rightVol - $inc)" -i audio-volume-medium -u low -t 1000 -r 9993 -h int:value:$rightVol
	elif [$muteOrNot = 'yes' ]; then
		dunstify "$(expr $rightVol - $inc)" -i mute -u low -t 1000 -r 9993 -h int:value:$rightVol
	fi
elif [ $action = 'mute' ]; then
	pactl set-sink-mute @DEFAULT_SINK@ toggle
		if [ $muteOrNot = 'no' ]; then
			dunstify "$rightVol" -i audio-volume-medium -u low -t 1000 -r 9993 -h int:value:$rightVol
  		elif [ $muteOrNot = 'yes' ]; then
			dunstify "$rightVol" -i mute -u low -t 1000 -r 9993 -h int:value:$rightVol
		fi
fi

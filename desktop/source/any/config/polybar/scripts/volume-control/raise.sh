#!/bin/bash

CURRENT_VOL=`pactl list sinks | perl -000ne 'if(/#1/){/(Volume:.*)/; print "$1\n"}' |awk '{print $12}' |sed 's/\%//g'`
MAX_VOL="140"

if [[ $CURRENT_VOL -gt $MAX_VOL ]] ;
then
    exit
else
    pactl set-sink-volume @DEFAULT_SINK@ +10%
    
fi


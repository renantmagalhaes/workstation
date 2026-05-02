#!/usr/bin/env bash
direction=$1
current=$(mmsg -g -t | awk '$2=="tag" && $4=="1" {print $3; exit}')
if [ "$direction" = "left" ]; then
    new=$((current - 1))
    if [ $new -lt 1 ]; then new=1; fi
else
    new=$((current + 1))
    if [ $new -gt 5 ]; then new=5; fi
fi
mmsg -d view,$new,1

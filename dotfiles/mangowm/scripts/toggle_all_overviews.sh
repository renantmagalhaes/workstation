#!/usr/bin/env bash
current_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')

for mon in $(mmsg -O); do
    mmsg -d focusmon,"$mon"
    mmsg -d toggleoverview
done

if [ -n "$current_mon" ]; then
    mmsg -d focusmon,"$current_mon"
fi

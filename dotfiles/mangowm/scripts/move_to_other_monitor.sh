#!/usr/bin/env bash
current_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')
other_mon=$(mmsg -O | grep -v "^$current_mon$" | head -n 1)

if [ -n "$other_mon" ]; then
    mmsg -d tagmon,"$other_mon"
fi

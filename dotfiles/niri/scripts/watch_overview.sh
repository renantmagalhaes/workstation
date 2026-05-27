#!/usr/bin/env bash

declare -A initial_titles

for mon in $(mmsg -O); do
    initial_titles["$mon"]=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "title" {print substr($0, index($0, $3)); exit}')
done

while true; do
    sleep 0.1
    mode=$(mmsg -g -b | awk '$2 == "keymode" {print $3; exit}')
    if [ "$mode" != "overview" ]; then
        exit 0
    fi

    for mon in $(mmsg -O); do
        curr=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "title" {print substr($0, index($0, $3)); exit}')
        if [ "$curr" != "${initial_titles["$mon"]}" ]; then
            mmsg -d setkeymode,default
            exit 0
        fi
    done
done

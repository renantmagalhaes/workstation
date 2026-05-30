#!/usr/bin/env bash

declare -A initial_layouts

for mon in $(mmsg -O); do
    initial_layouts["$mon"]=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "layout" {print $3; exit}')
done

while true; do
    sleep 0.1
    mode=$(mmsg -g -b | awk '$2 == "keymode" {print $3; exit}')
    if [ "$mode" != "overview" ]; then
        exit 0
    fi

    for mon in $(mmsg -O); do
        curr_layout=$(mmsg -g | awk -v m="$mon" '$1 == m && $2 == "layout" {print $3; exit}')
        
        layout_changed=false
        if [ "${initial_layouts["$mon"]}" = "󰃇" ] && [ "$curr_layout" != "󰃇" ]; then
            layout_changed=true
        fi
        if [ "$layout_changed" = true ]; then
            # A window was selected. Get the current active monitor.
            current_mon=$(mmsg -g | awk '$2 == "selmon" && $3 == "1" {print $1}')
            
            # Get the active tag of the selected window's monitor
            selected_tag=$(mmsg -g -t | awk -v m="$current_mon" '$1 == m && $2 == "tag" && $4 == "1" {print $3; exit}')
            
            # Disable overview on all monitors and synchronize their active tag
            for m in $(mmsg -O); do
                layout=$(mmsg -g | awk -v mon="$m" '$1 == mon && $2 == "layout" {print $3; exit}')
                if [ "$layout" = "󰃇" ]; then
                    mmsg -d focusmon,"$m"
                    mmsg -d toggleoverview
                fi
                
                if [ "$m" != "$current_mon" ] && [ -n "$selected_tag" ]; then
                    mmsg -d focusmon,"$m"
                    mmsg -d view,"$selected_tag",1
                fi
            done
            
            # Focus back on the monitor where the window was selected
            if [ -n "$current_mon" ]; then
                mmsg -d focusmon,"$current_mon"
            fi
            
            mmsg -d setkeymode,default
            exit 0
        fi
    done
done

#!/bin/bash

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

# Get active monitor details using the new mmsg JSON queries
client_json=$(mmsg get focusing-client 2>/dev/null)
if [ -n "$client_json" ] && [ "$client_json" != "null" ]; then
    fullscreen_state=$(echo "$client_json" | jq -r '.is_fullscreen // false')
    floating_state=$(echo "$client_json" | jq -r '.is_floating // false')
    client_width=$(echo "$client_json" | jq -r '.width // 0')
    client_height=$(echo "$client_json" | jq -r '.height // 0')
else
    fullscreen_state="false"
    floating_state="false"
    client_width=0
    client_height=0
fi

monitors_json=$(mmsg get all-monitors 2>/dev/null)
if [ -n "$monitors_json" ] && [ "$monitors_json" != "null" ]; then
    active_monitor=$(echo "$monitors_json" | jq -r '.monitors[] | select(.active) | .name')
    layout_symbol=$(echo "$monitors_json" | jq -r '.monitors[] | select(.active) | .layout_symbol')
    active_tag_clients=$(echo "$monitors_json" | jq -r '.monitors[] | select(.active) | .tags[] | select(.is_active) | .client_count // 0')
else
    active_monitor=""
    layout_symbol=""
    active_tag_clients=0
fi

# Convert true/false to 1/0 for existing compatibility
if [ "$fullscreen_state" = "true" ]; then fullscreen_state="1"; else fullscreen_state="0"; fi
if [ "$floating_state" = "true" ]; then floating_state="1"; else floating_state="0"; fi

show_indicator=0

if [ "$fullscreen_state" = "1" ]; then
    show_indicator=1
elif [ "$floating_state" = "0" ] && [ "${active_tag_clients:-0}" -gt 1 ] && [ -n "$client_width" ]; then
    # Get active monitor resolution
    read -r mon_width mon_height < <(wlr-randr | awk -v mon="$active_monitor" '
      $0 ~ "^" mon { flag = 1; next }
      /^[A-Z]/ { flag = 0 }
      flag && /^[ ]+[0-9]+x[0-9]+ px/ && /\(current\)/ {
        gsub(/px,/, "", $1)
        split($1, a, "x")
        print a[1], a[2]
        exit
      }
    ')
    
    if [ -n "$mon_width" ] && [ -n "$client_width" ]; then
        width_diff=$((mon_width - client_width))
        height_diff=$((mon_height - client_height))
        
        case "$layout_symbol" in
            S)
                # Horizontal scroller: only width matters
                if [ "$width_diff" -le 40 ]; then
                    show_indicator=1
                fi
                ;;
            VS)
                # Vertical scroller: only height matters
                if [ "$height_diff" -le 90 ]; then
                    show_indicator=1
                fi
                ;;
            *)
                # Other layouts: both width and height must be maximized
                if [ "$width_diff" -le 40 ] && [ "$height_diff" -le 90 ]; then
                    show_indicator=1
                fi
                ;;
        esac
    fi
fi

if [ "$show_indicator" = "1" ]; then
    # Window is fullscreen or maximized / proportion 1.0, show indicator
    echo " 󰊴 "
else
    # Show nothing (empty output hides the module)
    echo ""
fi

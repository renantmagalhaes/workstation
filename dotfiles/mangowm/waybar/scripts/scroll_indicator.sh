#!/bin/bash

action=$1

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

check_scroll() {
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

    client_json=$(mmsg get focusing-client 2>/dev/null)
    if [ -n "$client_json" ] && [ "$client_json" != "null" ]; then
        client_width=$(echo "$client_json" | jq -r '.width // 0')
    else
        client_width=0
    fi

    if [ -z "$active_monitor" ] || [ "$layout_symbol" != "S" ]; then
        return 1
    fi

    if [ "${active_tag_clients:-0}" -ge 3 ]; then
        return 0
    fi

    if [ "${active_tag_clients:-0}" -eq 2 ] && [ "$client_width" -gt 0 ]; then
        mon_width=$(wlr-randr | awk -v mon="$active_monitor" '
          $0 ~ "^" mon { flag = 1; next }
          /^[A-Z]/ { flag = 0 }
          flag && /^[ ]+[0-9]+x[0-9]+ px/ && /\(current\)/ {
            gsub(/px,/, "", $1)
            split($1, a, "x")
            print a[1]
            exit
          }
        ')

        if [ -n "$mon_width" ]; then
            width_diff=$((mon_width - client_width))
            if [ "$width_diff" -le 40 ]; then
                return 0
            fi
        fi
    fi

    return 1
}

if [ "$action" = "left" ]; then
    if check_scroll; then
        echo " 󰁍 "
    else
        echo ""
    fi
elif [ "$action" = "right" ]; then
    if check_scroll; then
        echo " 󰁔 "
    else
        echo ""
    fi
elif [ "$action" = "click_left" ]; then
    mmsg dispatch focusstack,prev
elif [ "$action" = "click_right" ]; then
    mmsg dispatch focusstack,next
fi

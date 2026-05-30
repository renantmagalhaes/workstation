#!/bin/bash

action=$1

check_scroll() {
    eval "$(mmsg -g | awk '
      $2 == "selmon" && $3 == "1" { active_mon = $1 }
      active_mon && $1 == active_mon {
        if ($2 == "tag") {
          if ($4 % 2 == 1) {
            active_tag_clients += $5
          }
        }
        if ($2 == "width") {
          client_width = $3
        }
        if ($2 == "layout") {
          layout_symbol = $3
        }
      }
      END {
        if (active_mon) {
          print "active_monitor=\"" active_mon "\""
          print "active_tag_clients=" (active_tag_clients ? active_tag_clients : 0)
          print "client_width=" (client_width ? client_width : 0)
          print "layout_symbol=\"" layout_symbol "\""
        }
      }
    ')"

    if [ -z "$active_monitor" ] || [ "$layout_symbol" != "S" ]; then
        return 1
    fi

    if [ "${active_tag_clients:-0}" -ge 3 ]; then
        return 0
    fi

    if [ "${active_tag_clients:-0}" -eq 2 ] && [ -n "$client_width" ]; then
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
    mmsg -d focusstack,prev
elif [ "$action" = "click_right" ]; then
    mmsg -d focusstack,next
fi

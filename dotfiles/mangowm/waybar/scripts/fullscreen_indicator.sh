#!/bin/bash

# Get all active monitor information from mmsg -g
eval "$(mmsg -g | awk '
  $2 == "selmon" && $3 == "1" { active_mon = $1 }
  active_mon && $1 == active_mon {
    if ($2 == "tag") {
      if ($4 % 2 == 1) {
        active_tag_clients += $5
      }
    }
    if ($2 == "fullscreen") print "fullscreen_state=" $3
    if ($2 == "floating") print "floating_state=" $3
    if ($2 == "width") print "client_width=" $3
    if ($2 == "height") print "client_height=" $3
    if ($2 == "layout") print "layout_symbol=\"" $3 "\""
  }
  END {
    if (active_mon) {
      print "active_monitor=\"" active_mon "\""
      print "active_tag_clients=" (active_tag_clients ? active_tag_clients : 0)
    }
  }
')"

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

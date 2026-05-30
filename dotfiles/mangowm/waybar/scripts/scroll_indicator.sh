#!/bin/bash

action=$1

check_scroll() {
    mmsg -g | awk '
    $2 == "selmon" && $3 == "1" { selmon = $1 }
    $2 == "layout" { layout[$1] = $3 }
    $2 == "tag" && $4 == "1" { clients[$1] = $5 }
    END {
        if (selmon && layout[selmon] == "S" && clients[selmon] >= 3) {
            exit 0
        }
        exit 1
    }
    '
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

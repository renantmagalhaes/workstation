#!/bin/env bash

if cat /sys/class/leds/*::capslock/brightness 2>/dev/null | grep -q 1; then
    echo "Caps Lock active"
else
    echo ""
fi


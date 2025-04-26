#!/bin/bash

notify-send "  Memory hogs" "$(ps axch -o cmd:15,%mem --sort=-%mem | head)"
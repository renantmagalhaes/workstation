#!/bin/bash

mon=`bspc query -D -d focused --names | cut -c1` && bspc desktop --focus $((mon)) && bspc desktop --focus $((mon + 1))$((mon + 1)) && bspc desktop --focus $((mon + 1))
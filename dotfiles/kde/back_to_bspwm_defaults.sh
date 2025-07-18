#!/bin/bash

# Polybar
rm -rf ~/.config/polybar
ln -s -f ../polybar/ ~/.config/polybar

# sxhkd
rm -rf ~/.config/sxhkd
mkdir -p ~/.config/sxhkd
ln -s -f ../bspwm/sxhkdrc ~/.config/sxhkd/sxhkdrc

# jgmenu
rm -rf ~/.config/jgmenu
ln -s -f ../bspwm/jgmenu ~/.config/jgmenu
#!/bin/bash

# Polybar
rm -rf ~/.config/polybar
ln -s -f $PWD/polybar ~/.config/polybar

# sxhkd
rm -rf ~/.config/sxhkd
ln -s -f $PWD/sxhkd ~/.config/sxhkd

# jgmenu
rm -rf ~/.config/jgmenu
ln -s -f $PWD/jgmenu ~/.config/jgmenu


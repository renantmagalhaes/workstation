#!/bin/bash

#BSPWM for kde
rm -rf ~/.config/bspwm
mkdir -p ~/.config/bspwm
ln -s -f $PWD/bspwmrc ~/.config/bspwm/bspwmrc

#sxhkdrc for kde
rm -rf ~/.config/sxhkd
mkdir -p ~/.config/sxhkd
ln -s -f $PWD/sxhkdrc ~/.config/sxhkd/sxhkdrc

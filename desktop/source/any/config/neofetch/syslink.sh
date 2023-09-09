#!/bin/bash

#remove neofetch folder
rm -rf ~/.config/neofetch/
# copy config
ln -s -f $PWD ~/.config/neofetch

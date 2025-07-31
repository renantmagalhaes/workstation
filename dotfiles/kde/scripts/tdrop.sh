#!/bin/bash

export DISPLAY=:0
export XAUTHORITY="/tmp/tdrop-auth-$$"
rm -f "$XAUTHORITY"

# Inject known-good cookie manually
xauth -f "$XAUTHORITY" add mainframe/unix:0 MIT-MAGIC-COOKIE-1 eaeb955937e80b5431543964b9eb5a8b

# Launch tdrop with valid X access
tdrop -ma -w 2508 -x 26 -y 45 -h 80% -s dropdown kitty --title kitty-tdrop

#!/bin/bash

# repository
git clone https://github.com/tcorreabr/Parachute.git ~/GIT-REPOS/CORE/Parachute


# install app
cd ~/GIT-REPOS/CORE/Parachute
make install

# bind meta key
kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Parachute"
qdbus-qt5 org.kde.KWin /KWin reconfigure
#qdbus org.kde.KWin /KWin reconfigure



# Revert bind key
# But manually editing that ~/.config/kwinrc file and deleting the line for binding the key under ModifierOnlyShortcuts did actually work!
# Thanks for the suggestion :D

# Okay fixed / worked around this issue.
# Using ksuperkey and assiged that pressing meta key provkes the standard parachute keyboarshortcut.

# ksuperkey -e 'Super_L=Control_L|Super_L|D'
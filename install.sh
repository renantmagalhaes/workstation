#!/bin/bash

#Root check
#if [ “$(id -u)” != “0” ]; then
#clear
#echo -e “This script must be run as root '\n' sudo ./install.sh” 2>&1
#exit 1
#fi


echo "#### Menu Selector ####"
echo " 1) Install Main SO packages"
echo " 2) Install Tmux"
echo " 3) Install Oh my ZSH"
echo " 4) Install ZSH additional packages"
echo " 5) Install DEV packages"
echo " 6) Guake Settings"
echo " 9)Exit"

read n
case $n in
    1) bash desktop/0-DEB/0-Pop\!_OS.sh ;;
    2) bash tmux/tmux.sh ;;
    3) bash zsh/zsh.sh ;;
    4) bash zsh/zsh.sh ;;
    5) bash dev-tools/software.sh ;;
    6) guake --restore-preferences guake/rtm-guake-settings ;;
    9)  echo "Bye" || exit ;;
  *) echo "Invalid option";;
esac
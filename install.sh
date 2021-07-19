#!/bin/bash

# Root Verification 
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi


echo "#### Menu Selector ####"
echo " 1) Install Main SO packages"
echo " 2) Install Tmux"
echo " 3) Install Oh my ZSH"
echo " 4) Install ZSH additional packages"
echo " 5) Guake Settings"
echo " 6) Install DEV Tools"
echo " 7) Cron Jobs"
echo " ==== UTILS ===="
echo " 11) VirtualBox Extension Pack"
echo " 12) Deckboard"
echo " 13) NordVPN"
echo " 14) Git Config"

echo " ==============="
echo " 0)Exit"

read n
case $n in
    1) bash utils/os-selector/os-selector.sh ;;
    2) bash tmux/tmux.sh ;;
    3) bash zsh/zsh.sh ;;
    4) bash zsh/zsh.sh ;;
    5) guake --restore-preferences utils/guake/rtm-guake-settings && echo "Done" ;;
    6) bash dev-tools/software.sh ;;
    7) bash cron/cron-scripts.sh && echo "Done" ;;
# ===================================================================================
    11) bash utils/virtualbox/virtualbox-ext-pack.sh ;;
    12) bash utils/deckboard/deckboard.sh ;;
    13) sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) ;;
    14) bash utils/git-config/git-config.sh ;;
# ===================================================================================
    0)  echo "Bye" || exit ;;
# ===================================================================================
  *) echo "Invalid option";;
esac
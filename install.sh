#!/bin/bash

# Root Verification 
if [ “$(id -u)” = “0” ]; then
echo “Dont run this script as root” 2>&1
exit 1
fi


echo "#### Menu Selector ####"
echo " 1) Initial Setup"
echo " 2) Install Tmux"
echo " 3) Install Oh my ZSH"
echo " 4) Install ZSH additional packages"
echo " 5) Guake Settings"
echo " 6) Install DEV Tools"
echo " 7) Install DevOps Tools"
echo " ==== UTILS ===="
echo " 21) VirtualBox Extension Pack"
echo " 22) 1Password"
echo " 23) NordVPN"
echo " 24) Git Config"
echo " 25) Wallpapers"
echo " 26) Insync"
echo " ==== NIX ===="
echo " 41) Nix package manager"
echo " 42) Install NIX base OS packages"
echo " ==== EXTRA ===="
echo " 51) Custom grub2 screen"
echo " ==============="
echo " 99) Post-Installation Instructions"
echo " ==============="
echo " 0) Exit"

read n
case $n in
    1) bash utils/os-selector/os-selector.sh ;;
    2) bash tmux/tmux.sh ;;
    3) bash zsh/zsh.sh ;;
    4) bash zsh/zsh.sh ;;
    5) guake --restore-preferences utils/guake/rtm-guake-settings && echo "Done" ;;
    6) bash dev-tools/software.sh ;;
    7) bash dev-tools/devops.sh ;;
# ===================================================================================
    21) bash utils/virtualization/virtualbox/virtualbox-ext-pack.sh ;;
    22) bash utils/1password/install-1password.sh ;;
    23) sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) && sudo usermod -aG nordvpn $USER && sudo systemctl enable --now nordvpnd.service && clear && echo "~~~~~~~~~~~~~\nIf NordVPN is slow, try to change the protocol from Nordlynx to OpenVPN \nnordvpn set technology OpenVPN\n~~~~~~~~~~~~~";;
    24) bash utils/git-config/git-config.sh ;;
    25) bash utils/wallpapers/wallpapers.sh ;;
    26) bash utils/insync/insync-install.sh ;;
# ===================================================================================
    41) sh <(curl -L https://nixos.org/nix/install) --daemon ;;
    42) bash desktop/source/nix/base-packages.sh ;;
# ===================================================================================
    51) sudo bash utils/grub2-customizer/custom-grub2.sh ;;
# ===================================================================================
    99) bash utils/post-install/env-detector.sh ;;
# ==================================================================================
    0)  echo "Bye" || exit ;;
# ===================================================================================
  *) echo "Invalid option";;
esac
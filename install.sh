#!/bin/bash

# Root Verification
if [ “$(id -u)” = “0” ]; then
	echo “Dont run this script as root” 2>&1
	exit 1
fi

# Menu
cat <<"EOF"
                    ██████  ████████ ███    ███                                            
                    ██   ██    ██    ████  ████                                            
                    ██████     ██    ██ ████ ██                                            
                    ██   ██    ██    ██  ██  ██                                            
                    ██   ██    ██    ██      ██                                            
                                                                                           
                                                                                           
██     ██  ██████  ██████  ██   ██ ███████ ████████  █████  ████████ ██  ██████  ███    ██ 
██     ██ ██    ██ ██   ██ ██  ██  ██         ██    ██   ██    ██    ██ ██    ██ ████   ██ 
██  █  ██ ██    ██ ██████  █████   ███████    ██    ███████    ██    ██ ██    ██ ██ ██  ██ 
██ ███ ██ ██    ██ ██   ██ ██  ██       ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██ 
 ███ ███   ██████  ██   ██ ██   ██ ███████    ██    ██   ██    ██    ██  ██████  ██   ████ 
EOF
echo ""
echo ""
echo "#### Menu Selector ####"
echo " 1) Full Workstation setup"
echo ""
echo "#### Individual Packages ####"
echo " 2) Install Tmux"
echo " 3) Install ZSH setup"
echo " 4) Guake Settings"
echo " 5) Install DEV Tools"
echo " 6) Install DevOps Tools"
echo " 7) Install Security Tools Tools"
echo ""
echo " ==== UTILS ===="
echo " 21) VirtualBox Extension Pack"
echo " 22) 1Password"
echo " 23) NordVPN"
echo " 24) Git Config"
echo " 25) Wallpapers"
echo " 26) Insync"
echo ""
echo " ==== WindowManager ===="
echo " 31) BSPWM"
echo " 32) Rofi"
echo " 33) Polybar"
echo " 34) Hyprland"
echo ""
echo " ==== NIX ===="
echo " 41) Nix package manager"
echo " 42) Install NIX BASE packages"
echo " 43) Install NIX extra packages"
echo ""
echo " ==== EXTRA ===="
echo " 91) Custom grub2 screen"
echo " 99) Post-Installation Instructions"
echo " ==============="
echo ""
echo " 0) Exit"

read -r n
case $n in
1) bash utils/os-selector/os-selector.sh ;;
2) bash ./scripts/tmux.sh ;;
3) bash ./scripts/zsh.sh ;;
4) guake --restore-preferences dotfiles/guake/rtm-guake-settings && echo "Done" ;;
5) bash ./DevSecTools/software.sh ;;
6) bash ./DevSecTools/devops.sh ;;
7) bash ./DevSecTools/security.sh ;;
	# ===================================================================================
21) bash utils/virtualization/virtualbox/virtualbox-ext-pack.sh ;;
22) bash utils/1password/install-1password.sh ;;
23) sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh) && sudo usermod -aG nordvpn $USER && sudo systemctl enable --now nordvpnd.service && clear && echo "~~~~~~~~~~~~~\nIf NordVPN is slow, try to change the protocol from Nordlynx to OpenVPN \nnordvpn set technology OpenVPN\n~~~~~~~~~~~~~" ;;
24) bash utils/git-config/git-config.sh ;;
25) bash utils/wallpapers/wallpapers.sh ;;
26) bash utils/insync/insync-install.sh ;;
	# ===================================================================================
31) bash ./scripts/bspwm.sh ;;
32) bash ./scripts/rofi.sh ;;
33) bash ./scripts/polybar.sh ;;
34) bash ./scripts/hyprland.sh ;;
	# ===================================================================================
41) bash ./scripts/nix-install.sh ;;
42) bash ./OperatingSystem/nix-basesystem.sh ;;
43) bash ./OperatingSystem/nix-packages.sh ;;
	# ===================================================================================
91) sudo bash utils/grub2-customizer/custom-grub2.sh ;;
	# ===================================================================================
99) bash utils/post-install/env-detector.sh ;;
	# ==================================================================================
0) echo "Bye" || exit ;;
	# ===================================================================================
*) echo "Invalid option" ;;
esac

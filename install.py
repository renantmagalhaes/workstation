#!/usr/bin/env python3

import subprocess

def base_setup():
    subprocess.run(["bash", "utils/os-selector/os-selector.sh"])
    # subprocess.run(["bash", "scripts/tmux.sh"])
    # subprocess.run(["bash", "scripts/zsh.sh"])
    # subprocess.run(["bash", "scripts/alacritty.sh"])
    # subprocess.run(["guake", "--restore-preferences", "utils/guake/rtm-guake-setting"])
    # subprocess.run(["bash", "scripts/neofetch.sh"])
    # subprocess.run(["bash", "utils/git-config/git-config.sh"])
    subprocess.run(["zsh"])

def install_bspwm():
    subprocess.run(["bash", "scripts/bspwm.sh"])

def install_rofi():
    subprocess.run(["bash", "scripts/rofi.sh"])

def install_polybar():
    subprocess.run(["bash", "scripts/polybar.sh"])

actions = {
    1: ("Workstation base setup", base_setup),
    0000: ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", ),
    22: ("BSPWM", install_bspwm),
    23: ("Rofi", install_rofi),
    24: ("polybar", install_polybar),

    # Add other actions...
}

def main():
    print("#### Menu Selector ####")
    for key in actions:
        print(f"{key}) {actions[key][0]}")
    print("0) Exit")

    choices = input("Enter your choice(s) separated by space: ").split()

    for choice in choices:
        choice = int(choice)
        if choice == 0:
            print("Exiting...")
            break
        elif choice in actions:
            print(f"Executing: {actions[choice][0]}")
            actions[choice][1]()
        else:
            print("Invalid option")

if __name__ == "__main__":
    main()


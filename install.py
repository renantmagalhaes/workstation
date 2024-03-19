#!/usr/bin/env python3

import subprocess

def initial_setup():
    subprocess.run(["bash", "utils/os-selector/os-selector.sh"])
    subprocess.run(["bash", "scripts/tmux.sh"])
    subprocess.run(["bash", "scripts/zsh.sh"])
    subprocess.run(["bash", "scripts/alacritty.sh"])
    subprocess.run(["bash", "scripts/neofetch.sh"])
    subprocess.run(["bash", "utils/git-config/git-config.sh"])


# Add more functions for other actions...

actions = {
    1: ("Workstation base setup", initial_setup),
    #2: ("Install BSPWM", install_bspwm),
    #3: ("Install Oh my ZSH", install_oh_my_zsh),
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


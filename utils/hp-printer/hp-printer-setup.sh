#!/bin/bash

# HP USB Printer Setup on Linux (CLI Only)
# ----------------------------------------
#
# 1. Confirm HPLIP is installed:
#    sudo hp-info
#
# 2. Connect the printer via USB.
#
# 3. Check if the printer is detected by USB subsystem:
#    lsusb
#
#    Example expected output:
#    Bus 001 Device 007: ID 03f0:0053 HP, Inc DeskJet 2620 All-in-One Printer
#
#    In this case USB ID is "001:007".
#
# 4. Run HPLIP setup in CLI/interactive mode:
#    sudo hp-setup -i 001:007
#
#    Or, let hp-setup detect automatically:
#    sudo hp-setup -i --auto 001:007
#
# 5. If setup fails due to "plugin missing", install the HP plugin:
#    sudo hp-plugin
#
# 6. Verify that the printer is now added in CUPS:
#    lpstat -t
#
# 7. Print a test page from the terminal:
#    lp /usr/share/cups/data/testprint
#
# 8. Optional: Open CUPS interface to check queue status:
#    http://localhost:631

# check cmd function
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y install hplip xsane sane
    hp-setup
elif check_cmd dnf; then
    sudo dnf install -y hplip xsane libsane-hpaio libinsane-devel hplip-gui
    hp-setup
elif check_cmd zypper; then
    sudo zypper install -y hplip xsane libinsane-devel hplip-utils hplip-sane
    hp-setup
else
    echo "system not found"
    fi

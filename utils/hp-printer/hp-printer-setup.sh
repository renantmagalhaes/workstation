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
# 5. MANDATORY on many models (confirmed on DeskJet 2600 series): install
#    the HP proprietary plugin. Without it, jobs show as "printing"/
#    completed in CUPS but nothing ever comes out of the printer:
#    hp-plugin
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

# Make sure the invoking user is allowed to administer CUPS (add/remove
# printers). Some distros (e.g. a minimal openSUSE install) ship cupsd
# with "SystemGroup root" only, which locks out every non-root user and
# makes hp-setup fail with a permission/auth error even with a correct
# password. This creates/uses the "lpadmin" group instead of requiring
# the user to be added to "root".
ensure_cups_admin() {
    local user="${SUDO_USER:-$USER}"

    sudo groupadd -f lpadmin
    sudo usermod -aG lpadmin "$user"

    if sudo grep -qi '^SystemGroup' /etc/cups/cups-files.conf; then
        sudo grep -qi '^SystemGroup.*\blpadmin\b' /etc/cups/cups-files.conf || \
            sudo sed -i 's/^\(SystemGroup .*\)$/\1 lpadmin/' /etc/cups/cups-files.conf
    else
        echo "SystemGroup lpadmin" | sudo tee -a /etc/cups/cups-files.conf >/dev/null
    fi

    sudo systemctl restart cups
}

# Launch hp-setup with the lpadmin group applied to this process tree
# right away, so you don't have to log out/in for the new group
# membership to take effect.
run_hp_setup() {
    sg lpadmin -c "hp-setup"
}

# MANDATORY (not optional): many HP printers, including the DeskJet 2600
# series, need HP's proprietary closed-source plugin to actually process
# a print job. Without it, CUPS happily reports the job as
# "printing"/completed but the printer never produces a page - this
# looks like everything worked, so it's easy to skip and miss.
# hp-plugin downloads it from HP and installs it; requires network access
# and will prompt for root via sudo/PolicyKit, so run it interactively.
install_hp_plugin() {
    echo
    echo "################################################################"
    echo "#  MANDATORY STEP: installing the HP proprietary print plugin  #"
    echo "#  Skipping this = jobs silently vanish (CUPS says 'printing', #"
    echo "#  nothing comes out of the printer). Follow the prompts.      #"
    echo "################################################################"
    echo
    hp-plugin
    echo
    echo "Verifying plugin install..."
    hp-check -t 2>&1 | grep -i plugin
}

if check_cmd apt-get; then # FOR DEB SYSTEMS
    sudo apt-get install -y install hplip xsane sane
    ensure_cups_admin
    run_hp_setup
    install_hp_plugin
elif check_cmd dnf; then
    sudo dnf install -y hplip xsane libsane-hpaio libinsane-devel hplip-gui
    ensure_cups_admin
    run_hp_setup
    install_hp_plugin
elif check_cmd zypper; then
    sudo zypper install -y hplip xsane libinsane-devel hplip-utils hplip-sane
    ensure_cups_admin
    run_hp_setup
    install_hp_plugin
else
    echo "system not found"
    fi

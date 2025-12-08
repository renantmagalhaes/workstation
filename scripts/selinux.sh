#!/bin/bash

# This script sets SELinux to permissive mode immediately
# and configures it to remain in permissive mode after reboots.

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# --- Step 1: Set SELinux to permissive mode for the current session ---

# Check the current SELinux status
CURRENT_STATUS=$(getenforce)
echo "Current SELinux status is: $CURRENT_STATUS"

if [ "$CURRENT_STATUS" != "Disabled" ]; then
  echo "Setting SELinux to permissive mode for the current session..."
  setenforce 0
  if [ $? -eq 0 ]; then
    echo "Successfully set SELinux to permissive mode."
    echo "New SELinux status is: $(getenforce)"
  else
    echo "Failed to set SELinux to permissive mode."
    exit 1
  fi
else
  echo "SELinux is disabled. Cannot change to permissive mode without a reboot after enabling."
  echo "Please enable SELinux in /etc/selinux/config and reboot."
fi

# --- Step 2: Make the permissive mode setting persistent across reboots ---

SELINUX_CONFIG="/etc/selinux/config"

if [ -f "$SELINUX_CONFIG" ]; then
  echo "Updating $SELINUX_CONFIG to set SELINUX=permissive for future boots..."
  # Use sed to replace the line starting with SELINUX= with SELINUX=permissive
  sed -i 's/^SELINUX=.*/SELINUX=permissive/' "$SELINUX_CONFIG"
  if [ $? -eq 0 ]; then
    echo "Successfully updated $SELINUX_CONFIG."
    echo "SELinux will be in permissive mode after the next reboot."
  else
    echo "Failed to update $SELINUX_CONFIG."
    exit 1
  fi
else
  echo "SELinux configuration file not found at $SELINUX_CONFIG."
  exit 1
fi

echo "Script execution complete. You can now run your other scripts."

echo "Fixing input udev rules for /dev/uinput..." 
set -e

RULE_FILE="/etc/udev/rules.d/40-uinput.rules"

echo "==> Creating udev rule for /dev/uinput..."
sudo bash -c "cat > $RULE_FILE" <<EOF
KERNEL=="uinput", GROUP="input", MODE="0660"
EOF

echo "==> Udev rule written to $RULE_FILE"
echo "     KERNEL==\"uinput\", GROUP=\"input\", MODE=\"0660\""

echo "==> Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "==> Reloading uinput kernel module..."
sudo modprobe -r uinput 2>/dev/null || true
sudo modprobe uinput

echo "==> Checking /dev/uinput permissions..."
ls -l /dev/uinput || { echo "ERROR: /dev/uinput does not exist"; exit 1; }

PERM=$(stat -c "%a" /dev/uinput)
OWNER=$(stat -c "%U" /dev/uinput)
GROUP=$(stat -c "%G" /dev/uinput)

echo "Permissions: $PERM, owner: $OWNER, group: $GROUP"

if [[ "$PERM" == "660" && "$GROUP" == "input" ]]; then
    echo "==> SUCCESS: /dev/uinput is now writable by group 'input'"
    exit 0
else
    echo "==> FAILURE: /dev/uinput did not get the correct permissions"
    echo "Expected: mode 660, group input"
    exit 1
fi

exit 0

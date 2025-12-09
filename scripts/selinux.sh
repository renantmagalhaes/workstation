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



echo "Fixing persistent udev rules and module loading for /dev/uinput..."

set -e

RULE_FILE="/etc/udev/rules.d/99-uinput.rules"
MODULE_FILE="/etc/modules-load.d/uinput.conf"

echo "==> Writing persistent udev rule to $RULE_FILE..."
sudo bash -c "cat > $RULE_FILE" <<EOF
KERNEL=="uinput", GROUP="input", MODE="0660"
EOF

echo "Rule created. Content:"
cat "$RULE_FILE"

echo
echo "==> Ensuring the uinput module loads correctly at boot..."
sudo bash -c "echo uinput > $MODULE_FILE"

echo "Module load file created at $MODULE_FILE"
cat "$MODULE_FILE"

echo
echo "==> Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo
echo "==> Reloading the uinput kernel module..."
sudo modprobe -r uinput 2>/dev/null || true
sudo modprobe uinput

echo
echo "==> Checking /dev/uinput permissions..."
if [[ ! -e /dev/uinput ]]; then
    echo "ERROR: /dev/uinput does not exist after reload"
    exit 1
fi

ls -l /dev/uinput

PERM=$(stat -c "%a" /dev/uinput)
OWNER=$(stat -c "%U" /dev/uinput)
GROUP=$(stat -c "%G" /dev/uinput)

echo "Permissions reported: $PERM, owner $OWNER, group $GROUP"

if [[ "$PERM" == "660" && "$GROUP" == "input" ]]; then
    echo "==> SUCCESS. /dev/uinput is correctly configured and now persistent across reboots."
else
    echo "==> FAILURE. Permissions are not correct."
    echo "Expected: mode 660, group input"
    echo "Found: mode $PERM, group $GROUP"
    echo "A fallback fix is possible using /etc/tmpfiles.d if needed."
    exit 1
fi

echo
echo "Validation complete. Reboot to confirm persistence."


exit 0

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

exit 0
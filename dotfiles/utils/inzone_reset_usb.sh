#!/bin/bash

# Find Sony Inzone based on name match only
line=$(lsusb | grep -i "INZONE")
if [ -z "$line" ]; then
    line=$(lsusb | grep -i "Sony")
fi

if [ -z "$line" ]; then
    echo "Sony Inzone dongle not found in lsusb"
    exit 1
fi

echo "$line"

bus=$(echo "$line" | awk '{print $2}')
dev=$(echo "$line" | awk '{print $4}' | sed 's/://')

devpath="/dev/bus/usb/$bus/$dev"

# Query udev for the actual sysfs path that represents this USB device
sys_path=$(udevadm info -q path -n "$devpath")

if [ -z "$sys_path" ]; then
    echo "udevadm could not resolve the sysfs path"
    exit 1
fi

# Full real path in sysfs
full="/sys${sys_path}"

echo "Resolved sysfs path:"
echo "$full"

# Get the closest parent folder that represents a physical USB port
port=$(basename "$full")

echo "Resetting USB port: $port"

# Check if running as root (via pkexec), if not use sudo
if [ "$EUID" -eq 0 ]; then
    echo "$port" | tee /sys/bus/usb/drivers/usb/unbind >/dev/null
    sleep 1
    echo "$port" | tee /sys/bus/usb/drivers/usb/bind >/dev/null
else
    echo "$port" | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null
    sleep 1
    echo "$port" | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null
fi

echo "Done. Sony Inzone dongle reset."

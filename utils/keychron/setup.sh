#!/bin/bash

# Verifications 
if [ “$(id -u)” != “0” ]; then
echo “run this script as root” 2>&1
exit 1
fi

## Makefile
cat <<EOF > /etc/systemd/system/keychron.service
[Unit]
Description=The command to make the Keychron K2 work

[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo 0 > /sys/module/hid_apple/parameters/fnmode"

[Install]
WantedBy=multi-user.target
EOF

# Enable module
systemctl enable keychron

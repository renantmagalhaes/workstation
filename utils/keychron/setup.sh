#!/bin/bash


## Makefile
cat <<EOF >> /etc/systemd/system/keychron.service
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

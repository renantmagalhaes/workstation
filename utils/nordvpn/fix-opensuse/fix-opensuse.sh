#!/bin/bash
touch /run/openvpn/nordvpnd.sock
sudo systemctl enable --now nordvpnd.service

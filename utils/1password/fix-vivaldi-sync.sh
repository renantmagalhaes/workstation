#!/bin/bash


sudo mkdir -p  /etc/1password
sudo cp custom_allowed_browsers /etc/1password/custom_allowed_browsers
sudo chown root:root /etc/1password/custom_allowed_browsers && sudo chmod 755 /etc/1password/custom_allowed_browsers

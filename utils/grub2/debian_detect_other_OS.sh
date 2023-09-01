#!/bin/bash

# Uncomment OS prober
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/g' /etc/default/grub

# Update grub2 config
sudo update-grub
#!/bin/bash


# Enable remeber choice
sudo sed -e 's/\#\ GRUB\_SAVEDEFAULT\=\"true\"/GRUB\_SAVEDEFAULT\=\"true\"/g' /etc/default/grub

# Re-generate grub2 config
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

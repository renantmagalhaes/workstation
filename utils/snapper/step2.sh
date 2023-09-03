#!/bin/bash

sudo rm -R /btrfsroot/@rootfs/home/$(whoami)

sudo btrfs subvol create /btrfsroot/@var@log

sudo cp -RT --reflink=always /var/log /btrfsroot/@var@log

printf "$(df --output=source / | tail -n 1) /var/log    btrfs    defaults,subvol=@var@log    0    0\n" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo mount /var/log

sudo rm -rf /btrfsroot/@rootfs/var/log/*

sudo btrfs subvol create /btrfsroot/@tmp
sudo cp -RT --reflink=always /tmp /btrfsroot/@tmp
printf "$(df --output=source / | tail -n 1) /tmp    btrfs    defaults,subvol=@tmp    0    0\n" | sudo tee -a /etc/fstab

sudo shutdown -r now

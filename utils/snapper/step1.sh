#!/bin/bash

sudo apt-get install -y btrfs-progs python3-btrfsutil gawk inotify-tools make build-essential git

sudo mkdir -p /btrfsroot

printf "$(df --output=source / | tail -n 1) /btrfsroot    btrfs    defaults,subvolid=5    0    0\n" | sudo tee -a /etc/fstab

sudo mount /btrfsroot

systemctl daemon-reload

sudo btrfs subvol create /btrfsroot/@home

sudo cp -R --reflink=always /home/$(whoami) /btrfsroot/@home

sudo chown -R $(whoami):$(whoami) /btrfsroot/@home/$(whoami)

printf "$(df --output=source / | tail -n 1) /home    btrfs    defaults,subvol=@home    0    0\n" | sudo tee -a /etc/fstab

sudo shutdown -r now

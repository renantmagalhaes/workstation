#!/bin/bash

sudo rm -rf /btrfsroot/@rootfs/tmp/*
sudo rm -rf /btrfsroot/@rootfs/tmp/.*

sudo apt-get install -y snapper snapper-gui

sudo snapper -c root create-config /

sudo btrfs subvol create /btrfsroot/@snapshots

sudo mkdir -p /.snapshots

printf "$(df --output=source / | tail -n 1) /.snapshots    btrfs    defaults,subvol=@snapshots    0    0\n" | sudo tee -a /etc/fstab
sudo mount /.snapshots

cd /tmp
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make
sudo make install

sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd

sudo update-grub

cd .. 
git clone https://github.com/jrabinow/snapper-rollback.git
cd snapper-rollback
sudo cp snapper-rollback.py /usr/local/bin/snapper-rollback
sudo cp snapper-rollback.conf /etc/
sudo sed -i 's/subvol_main = @/subvol_main = @rootfs/g' /etc/snapper-rollback.conf




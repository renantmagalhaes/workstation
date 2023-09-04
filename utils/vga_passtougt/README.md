# GUIDE

Your os needs to be installed in UEFI mode run the command below to check

```bash
[ -d /sys/firmware/efi ] && echo "Installed in UEFI mode" |
```

sudo apt-get install -y python3-all pyflakes3 debhelper dh-python

cd /tmp/
git clone https://github.com/pop-os/kernelstub
cd kernelstub
sudo dpkg-buildpackage -b -us -uc
sudo dpkg -i ../kernelstub*.deb


sudo kernelstub -a "amd_iommu=on iommu=pt video=efifb:off"

sudo shutown -r now

check with: 
```bash
find /sys/kernel/iommu_groups/ -type l | sort -n -k5 -t/ | while read d; do n=${d#*/iommu_groups/*}; n=${n%%/*}; printf 'IOMMU Group %s ' "$n"; lspci -nns "${d##*/}"; done
``````

sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager ovmf


Once installed we need to edit the libvirt conf file


Once installed we need to edit the libvirt conf file
```
sudo nano /etc/libvirt/libvirtd.conf
```

Next find and uncomment the following lines 

```
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

Make sure this is at the end of the file (helps with logs)
```
log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"
```
### Give Permissions
Run the following to give your user the proper premissions

```
sudo usermod -a -G libvirt $(whoami)
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```
Check with 
```
sudo groups $(whoami)
```
Should show that you are in the group


### Change The Qemu Conf

Run the following below to edit the qemu file
```
sudo nano /etc/libvirt/qemu.conf
```
You want to change the following lines. Replace "your username" with your username
```
#user = "root" to user = "your username"
#group = "root" to group = "your username"
```
Now restart libvert
```
sudo systemctl restart libvirtd
```
Next we need to add the grouping
```
sudo usermod -a -G kvm,libvirt $(whoami)
sudo groups $(whoami)
```
Enabling network
```
sudo virsh net-autostart default
sudo virsh net-start default
```


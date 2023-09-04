# GUIDE

sudo apt-get install -y python3-all pyflakes3 debhelper dh-python

cd /tmp/
git clone https://github.com/pop-os/kernelstub
cd kernelstub
sudo dpkg-buildpackage -b -us -uc
sudo dpkg -i ../kernelstub*.deb


sudo kernelstub -a "amd_iommu=on iommu=pt video=efifb:off"


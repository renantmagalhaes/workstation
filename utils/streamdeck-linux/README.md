# Stream Deck for linux

## Installation on Suse

```bash
sudo zypper install libhidapi-libusb0 python310-devel kernel-devel
python3 -m pip install --upgrade pip
sudo sh -c 'echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0fd9\", TAG+=\"uaccess\"" > /etc/udev/rules.d/70-streamdeck.rules'
sudo udevadm trigger
python3 -m pip install streamdeck-ui --user
streamdeck
```

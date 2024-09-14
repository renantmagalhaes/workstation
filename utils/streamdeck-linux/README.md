# Stream Deck for linux

## Installation on Suse

```bash
sudo zypper install libhidapi-libusb0 python311-devel kernel-devel python311-streamdeck streamdeck-linux-gui
#python3 -m pip install --upgrade pip
sudo sh -c 'echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0fd9\", TAG+=\"uaccess\"" > /etc/udev/rules.d/70-streamdeck.rules'
sudo udevadm trigger
#python3 -m pip install streamdeck-ui --user
streamdeck
```

- [ ] ## Installation on Debian

```bash
sudo sh -c 'echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"0fd9\", TAG+=\"uaccess\"" > /etc/udev/rules.d/70-streamdeck.rules'
sudo udevadm trigger
sudo apt install -y libhidapi-libusb0 python3-pip python3-elgato-streamdeck streamdeck-ui
``````

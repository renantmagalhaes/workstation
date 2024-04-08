#!/bin/bash

## Droidcam
cd /tmp/
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_2.1.2.zip
unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client
sudo ./install-video

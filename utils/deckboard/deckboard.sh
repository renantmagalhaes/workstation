#!/bin/bash

# Download package
wget https://github.com/rivafarabi/deckboard/releases/download/v1.9.93/deckboard_1.9.93_amd64.deb -O /tmp/deckboard_1.9.93_amd64.deb

# Install package
sudo dpkg -i /tmp/deckboard_1.9.93_amd64.deb

# Install dependencies
sudo apt-get install -f
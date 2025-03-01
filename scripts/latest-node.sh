#!/bin/bash

# Install Node.js (Latest Current Version)
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install yarn
sudo npm install --global yarn
# Display installed versions
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)

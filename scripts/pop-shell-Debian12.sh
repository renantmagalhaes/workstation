#!/bin/bash

# Define the base directory for repositories
REPO_BASE_DIR="$HOME/GIT-REPOS/CORE"

# Create the base directory if it doesn't exist
mkdir -p "$REPO_BASE_DIR"

# Clone the pop-shell repository
echo "Cloning the pop-shell repository..."
git clone https://github.com/pop-os/shell.git "$REPO_BASE_DIR/shell"

# Navigate to the pop-shell directory
cd "$REPO_BASE_DIR/shell" || exit

# Install TypeScript globally if not already installed
echo "Installing TypeScript globally..."
sudo npm install -g typescript

# Check out the specific branch for installation
echo "Checking out the 'master_jammy' branch..."
git checkout master_jammy

# Perform the local installation
echo "Starting the local installation..."
make local-install

echo "Pop Shell installation completed successfully."

#!/bin/bash

# Function to get the latest release download URL for Linux
get_latest_podman_url() {
  curl -s https://api.github.com/repos/containers/podman/releases/latest | grep browser_download_url | grep "podman-remote-static-linux_amd64.tar.gz" | cut -d '"' -f 4
}

# Function to download and install Podman
install_podman() {
  local url=$(get_latest_podman_url)
  if [ -z "$url" ]; then
    echo "Failed to find the download URL for the latest Podman release."
    exit 1
  fi
  
  local filename=$(basename "$url")
  echo "Downloading $filename..."
  curl -LO "$url"
  
  echo "Extracting $filename..."
  tar -xzf "$filename"
  
  echo "Listing contents of the extracted tarball..."
  tar -tzf "$filename"
  
  echo "Installing Podman..."
  # Move and rename the binary
  if [ -f "bin/podman-remote-static-linux_amd64" ]; then
    sudo mv bin/podman-remote-static-linux_amd64 /usr/local/bin/podman
    sudo chmod +x /usr/local/bin/podman
  else
    echo "Failed to find the 'podman-remote-static-linux_amd64' binary in the extracted files."
    exit 1
  fi
  
  echo "Cleaning up..."
  rm -rf bin
  rm "$filename"
  
  echo "Podman installation complete!"
}

# Run the installation function
install_podman
podman machine init
podman machine start

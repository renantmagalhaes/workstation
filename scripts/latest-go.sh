#!/bin/bash
# Install GO
## Set up Go environment variables
GO_INSTALL_DIR="/usr/local/go"

## Remove any previous Go installation
if [ -d "$GO_INSTALL_DIR" ]; then
    echo "Removing previous Go installation from $GO_INSTALL_DIR"
    sudo rm -rf "$GO_INSTALL_DIR"
fi

## Fetch the latest version of Go
echo "Fetching the latest Go version..."
LATEST_GO_VERSION=$(wget -qO- https://go.dev/VERSION?m=text |head -n 1)

## Download the latest Go version
echo "Downloading Go $LATEST_GO_VERSION..."
wget https://go.dev/dl/$LATEST_GO_VERSION.linux-amd64.tar.gz -O /tmp/go.tar.gz

## Extract Go to the installation directory
echo "Extracting Go to $GO_INSTALL_DIR..."
sudo tar -C /usr/local/go -xzf /tmp/go.tar.gz

## Clean up the downloaded tar file
rm /tmp/go.tar.gz

## Set up Go environment by adding Go to the PATH in /etc/profile.d
sudo ln -s -f /usr/local/go/bin/go /usr/local/bin/go
sudo ln -s -f /usr/local/go/bin/gofmt /usr/local/bin/gofmt

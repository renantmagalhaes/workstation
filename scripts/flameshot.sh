#!/bin/bash

# Path to the flameshot config
CONFIG_FILE="$HOME/.config/flameshot/flameshot.ini"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_FILE")"

# Create the file with [General] header if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[General]" > "$CONFIG_FILE"
fi

# Function to update or add a key-value pair
update_config() {
    local key=$1
    local value=$2
    if grep -q "^$key=" "$CONFIG_FILE"; then
        # Key exists, update it
        sed -i "s/^$key=.*/$key=$value/" "$CONFIG_FILE"
    else
        # Key doesn't exist, add it under [General]
        sed -i "/^\[General\]/a $key=$value" "$CONFIG_FILE"
    fi
}

# Apply the fixes
update_config "disabledGrimWarning" "true"
update_config "useGrimAdapter" "true"

echo "Flameshot config updated successfully in $CONFIG_FILE"

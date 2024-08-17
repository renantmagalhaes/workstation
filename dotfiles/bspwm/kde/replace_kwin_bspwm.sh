#!/bin/bash

WM_PATH="/usr/bin/bspwm"

# Step 1: Mask the plasma-kwin_x11.service for the current user
echo "Masking plasma-kwin_x11.service..."
systemctl --user mask plasma-kwin_x11.service

# Step 2: Create the custom systemd user unit
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/plasma-custom-wm.service"

echo "Creating custom systemd user unit at $SERVICE_FILE..."
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=Plasma Custom Window Manager
Before=plasma-workspace.target

[Service]
ExecStart=$WM_PATH
Slice=session.slice
Restart=on-failure

[Install]
WantedBy=plasma-workspace.target
EOL

# Step 3: Reload systemd and enable the custom service
echo "Reloading systemd user units..."
systemctl --user daemon-reload

echo "Enabling the custom window manager service..."
systemctl --user enable plasma-custom-wm.service

echo "Done! You can now log out and log back in to start using your custom window manager."


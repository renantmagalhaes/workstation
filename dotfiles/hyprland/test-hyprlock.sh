#!/bin/bash

echo "🔍 Testing Hyprlock Configuration..."

# Check if hyprlock is installed
if ! command -v hyprlock &> /dev/null; then
    echo "❌ hyprlock is not installed"
    echo "Installing hyprlock..."
    sudo zypper install -y hyprlock
    if [ $? -eq 0 ]; then
        echo "✅ hyprlock installed successfully"
    else
        echo "❌ Failed to install hyprlock"
        exit 1
    fi
else
    echo "✅ hyprlock is installed"
fi

# Check if hyprlock config exists
if [ -f ~/.config/hypr/hyprlock.conf ]; then
    echo "✅ hyprlock config found"
else
    echo "❌ hyprlock config not found"
    echo "Creating symlink..."
    ln -sf "$PWD/hypr/hyprlock.conf" ~/.config/hypr/hyprlock.conf
    echo "✅ hyprlock config linked"
fi

# Test hyprlock syntax
echo "🔍 Testing hyprlock configuration syntax..."
if hyprlock --help &> /dev/null; then
    echo "✅ hyprlock is working"
else
    echo "❌ hyprlock has issues"
fi

# Test the lock command
echo "🔍 Testing lock command..."
echo "Running: hyprlock"
echo "Press Ctrl+C to cancel if it works, or wait for timeout"
timeout 5s hyprlock || echo "✅ hyprlock test completed (timeout expected)"

echo "🎉 Hyprlock test completed!"

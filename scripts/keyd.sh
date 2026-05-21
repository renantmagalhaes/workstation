#!/usr/bin/env bash
set -euo pipefail

# 1. Detect OS and install keyd natively
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu)
            echo "[-] Debian/Ubuntu detected. Installing keyd..."
            sudo apt-get update -y
            sudo apt-get install -y keyd
            SUDO_GROUP="sudo"
            ;;
        opensuse*|sles)
            echo "[-] openSUSE detected. Installing keyd..."
            sudo zypper --non-interactive in keyd
            SUDO_GROUP="wheel"
            ;;
        *)
            echo "[!] Unsupported distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "[!] /etc/os-release not found. Cannot determine distribution."
    exit 1
fi

# 2. Deploy system-wide keyd configuration (Mapped to Alt+Space)
echo "[-] Creating /etc/keyd/keyd.conf..."
sudo mkdir -p /etc/keyd

sudo tee /etc/keyd/keyd.conf > /dev/null << 'EOF'
[ids]
*

[global]
overload_tap_timeout = 300

[main]
leftmeta = overload(meta, macro(leftalt+space))
rightmeta = overload(meta, macro(leftalt+space))
EOF

# 4. Configure Passwordless Sudo Rule for systemctl control
echo "[-] Creating passwordless sudoers exception for $USER..."
sudo tee /etc/sudoers.d/99-mangowm-keyd > /dev/null << EOF
# Generated for MangoWM environment control
$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl start keyd.service, /usr/bin/systemctl stop keyd.service, /usr/bin/systemctl restart keyd.service
EOF

sudo chmod 0440 /etc/sudoers.d/99-mangowm-keyd

# 4. Ensure the service is DISABLED at system boot
echo "[-] Disabling keyd from general boot target..."
sudo systemctl disable keyd.service

echo "[+] Done! You can now add the following to your window manager configuration:"
echo "    exec-once = sudo systemctl start keyd.service"

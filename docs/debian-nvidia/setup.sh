#!/bin/bash
# Debian 13 + NVIDIA + MangoWM: automates steps 1-3 of README.md.
# Run with: bash docs/debian-nvidia/setup.sh
# Afterwards: reboot, enroll the MOK key, and set the BIOS to Discrete Graphics (README steps 2 and 4).
set -euo pipefail

echo "==> Hardware"
lspci -nnk | grep -A3 -Ei 'vga|3d|display' || true
mokutil --sb-state || true

echo "==> 1. Install the NVIDIA driver (DKMS)"
sudo apt update
sudo apt install -y linux-headers-amd64 nvidia-driver firmware-misc-nonfree

echo "==> 2. Queue MOK enrollment (Secure Boot)"
if mokutil --sb-state 2>&1 | grep -q 'SecureBoot enabled'; then
    if mokutil --list-enrolled 2>/dev/null | grep -qi 'DKMS module signing key'; then
        echo "DKMS key already enrolled, skipping."
    else
        echo "Choose a throwaway password (asked twice). You type it once at the blue MOK screen on reboot."
        sudo mokutil --import /var/lib/dkms/mok.pub
        mokutil --list-new || true
    fi
else
    echo "Secure Boot is off, nothing to enroll."
fi

echo "==> 3. NVIDIA power management + modeset (lets GDM offer Wayland sessions)"
echo 'options nvidia-current NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power.conf >/dev/null
echo 'options nvidia-drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia-drm.conf >/dev/null
sudo systemctl enable nvidia-suspend nvidia-resume nvidia-hibernate
sudo update-initramfs -u

cat <<'EOF'

Done. Next:
  1. sudo reboot
  2. At the blue MOK Manager screen: Enroll MOK > Continue > Yes > password > Reboot
  3. Hybrid laptop with external ports on NVIDIA: BIOS (F1) > Config > Display > Graphics Device > Discrete Graphics
  4. Log in with Mango (gear icon in GDM), then check: nvidia-smi ; ls -l /dev/dri/by-path/
EOF

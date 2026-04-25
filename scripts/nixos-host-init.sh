#!/bin/bash
# Detects this machine's boot setup and writes /etc/nixos/host.nix.
# Safe to re-run — will not overwrite an existing host.nix.

HOST_NIX="/etc/nixos/host.nix"

if [[ -f "$HOST_NIX" ]]; then
    echo "host.nix already exists at $HOST_NIX — skipping."
    exit 0
fi

# --- Detect UEFI vs BIOS ---
if [[ -d /sys/firmware/efi ]]; then
    IS_UEFI=true
else
    IS_UEFI=false
fi

# --- Detect EFI mount point ---
if $IS_UEFI; then
    if mountpoint -q /boot/efi 2>/dev/null; then
        EFI_MOUNT="/boot/efi"
    elif mountpoint -q /boot 2>/dev/null; then
        EFI_MOUNT="/boot"
    else
        echo "ERROR: UEFI detected but no EFI partition mounted at /boot/efi or /boot."
        echo "Mount your EFI partition first, then re-run this script."
        exit 1
    fi
fi

# --- Detect root disk for BIOS GRUB ---
if ! $IS_UEFI; then
    ROOT_PART=$(findmnt -n -o SOURCE / 2>/dev/null)
    # Strip partition number: /dev/sda2 -> /dev/sda, /dev/nvme0n1p2 -> /dev/nvme0n1
    ROOT_DISK=$(echo "$ROOT_PART" | sed 's/p\?[0-9]*$//')
    if [[ -z "$ROOT_DISK" ]]; then
        ROOT_DISK="/dev/sda"
        echo "Warning: could not detect root disk, defaulting to $ROOT_DISK"
    fi
fi

# --- Write host.nix ---
if $IS_UEFI; then
    sudo tee "$HOST_NIX" > /dev/null << EOF
{ ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "$EFI_MOUNT";
}
EOF
    echo "Generated UEFI/systemd-boot host.nix (EFI at $EFI_MOUNT)"
else
    sudo tee "$HOST_NIX" > /dev/null << EOF
{ ... }: {
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "$ROOT_DISK" ];
}
EOF
    echo "Generated BIOS/GRUB host.nix (device $ROOT_DISK)"
fi

echo "Written to $HOST_NIX"

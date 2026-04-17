{ config, pkgs, lib, ... }:

{
  # Default: systemd-boot (UEFI, EFI at /boot/efi).
  # Override in /etc/nixos/mounts.nix for GRUB machines:
  #   boot.loader.systemd-boot.enable = lib.mkForce false;
  #   boot.loader.grub = { enable = true; device = "nodev"; efiSupport = true; useOSProber = true; };
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 10;
    };
    efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = lib.mkDefault "/boot/efi";
    };
  };

  boot.initrd = {
    # Available for auto-detection
    availableKernelModules = [ 
      "ahci" "nvme" "xhci_pci" "usb_storage" "ata_piix" "uhci_hcd" 
    ];
    # Force-load these to ensure storage is found immediately
    kernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "sd_mod" "sr_mod" ];
  };

  # Use latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Clean /tmp on boot
  boot.tmp.cleanOnBoot = true;
}

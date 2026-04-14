{ config, pkgs, lib, ... }:

{
  # Agnostic GRUB Configuration
  boot.loader = {
    efi = {
      canTouchEfiVariables = lib.mkDefault false;
      efiSysMountPoint = "/boot"; # Standard mount point
    };
    grub = {
      enable = true;
      efiSupport = lib.mkDefault false;
      # "nodev" works for UEFI only. For Legacy BIOS, we need a device.
      # We use mkDefault so it's easy to override in host-specific configs.
      device = lib.mkDefault "/dev/sda"; 
      
      # Use this for UEFI-only machines or where legacy is not used:
      # device = "nodev"; 

      useOSProber = true;
      efiInstallAsRemovable = lib.mkDefault false; # Only for UEFI
    };
  };

  # Use latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Clean /tmp on boot
  boot.tmp.cleanOnBoot = true;
}

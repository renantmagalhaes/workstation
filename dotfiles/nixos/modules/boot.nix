{ config, pkgs, lib, ... }:

{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      efiInstallAsRemovable = lib.mkDefault false;
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

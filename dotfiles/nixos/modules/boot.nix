{ config, pkgs, ... }:

{
  # Bootloader is intentionally NOT configured here — it is machine-specific.
  # Each machine must have /etc/nixos/host.nix with its own bootloader config.
  #
  # UEFI + systemd-boot (most physical machines):
  #   boot.loader.systemd-boot.enable = true;
  #   boot.loader.efi.canTouchEfiVariables = true;
  #   boot.loader.efi.efiSysMountPoint = "/boot/efi"; # or "/boot"
  #
  # UEFI + GRUB (dual-boot with Windows):
  #   boot.loader.grub = { enable = true; device = "nodev"; efiSupport = true; useOSProber = true; };
  #   boot.loader.efi = { canTouchEfiVariables = true; efiSysMountPoint = "/boot/efi"; };
  #
  # BIOS + GRUB (VMs, legacy hardware):
  #   boot.loader.grub = { enable = true; device = "/dev/sda"; };

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

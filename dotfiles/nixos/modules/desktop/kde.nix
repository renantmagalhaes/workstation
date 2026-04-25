{ config, pkgs, ... }:

{
  # Enable KDE Plasma 6 (with SDDM)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true; # Force SDDM to use Wayland
  services.desktopManager.plasma6.enable = true;

  # KDE-specific packages
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.ark
    kdePackages.gwenview
  ];
}

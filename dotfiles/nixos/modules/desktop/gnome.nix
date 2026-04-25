{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment (with GDM)
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.defaultSession = "gnome";
  services.desktopManager.gnome.enable = true;

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
  ];
}

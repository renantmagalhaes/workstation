{ config, pkgs, ... }:

{
  # Enable KDE Plasma 6 (with SDDM)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true; 
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # KDE-specific packages
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.ark
    kdePackages.gwenview
    kdePackages.kdialog
    
    # Kvantum packages for both Qt6 (Plasma 6) and Qt5
    # kdePackages.qtstyleplugin-kvantum includes the Kvantum Manager
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
  ];
}

{ config, pkgs, lib, ... }:

let
  # Choose your desktop environment: "gnome" or "kde"
  desktopEnv = "kde"; 
in
{
  imports = [
    (if desktopEnv == "gnome" then ./desktop/gnome.nix else ./desktop/kde.nix)
  ];

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # GPU / graphics stack
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Disable the X11 windowing system (using Wayland-only)
  services.xserver.enable = false;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap (Still uses xserver module for global defaults)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Required for GTK apps to read dconf settings (dark mode, theme prefs)
  programs.dconf.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

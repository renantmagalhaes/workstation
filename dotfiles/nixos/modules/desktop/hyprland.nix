{ config, pkgs, inputs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    # Use the portal package from the hyprland module itself if needed,
    # but the default one is usually fine.
    xwayland.enable = true;
  };

  # Optional: Hint JS/Electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # System-level packages required for the Hyprland environment
  environment.systemPackages = with pkgs; [
    waybar
    mako
    rofi
    swww
    hyprlock
    hypridle
    hyprpicker
    hyprshot
    grim
    slurp
    wl-clipboard
    cliphist
    pavucontrol
    blueman
    playerctl
    pamixer
    libnotify
    xdg-utils
    hyprland-qtutils
    nwg-displays
    mate.mate-polkit
    # Using the quickshell package from the flake input
    inputs.quickshell.packages.${pkgs.system}.default
  ];

  # Security / Polkit
  security.polkit.enable = true;

  # Ensure user is in the right groups for desktop access
  users.users.rtm.extraGroups = [ "input" "video" ];

  # Screen sharing / Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}

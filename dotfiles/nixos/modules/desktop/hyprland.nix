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
    (pkgs.writeShellScriptBin "rofi" ''
      if [ "$DESKTOP_SESSION" = "gnome" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        exec env -u WAYLAND_DISPLAY ${pkgs.rofi}/bin/rofi "$@"
      else
        exec ${pkgs.rofi}/bin/rofi "$@"
      fi
    '')
    awww
    hyprlock
    hypridle
    hyprpicker
    hyprshot
    swappy
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
    mate-polkit
    jgmenu
    evtest
    pasystray
    nautilus
    zenity
    curl
    # Using the quickshell package from the flake input
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Security / Polkit
  security.polkit.enable = true;

  # Ensure user is in the right groups for desktop access
  users.users.rtm.extraGroups = [ "input" "video" ];

  # NOTE: Portals and XDG integration are now handled automatically by the 
  # official Hyprland flake module imported in flake.nix.
}

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/users.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/devops.nix
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/flatpaks.nix
    ./modules/apps/1password.nix
    ./modules/apps/vivaldi.nix
    ./modules/apps/google-chrome.nix
  ];

  home-manager.users.rtm = import ./home.nix;
  # Rename conflicting files instead of hard-failing activation
  home-manager.backupFileExtension = "bak";

  # Enable Native Steam (properly hooks up 32-bit libs and drivers)
  programs.steam.enable = true;

  # Enable flakes and the nix-command experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This now correctly matches the nixos-25.11 Nixpkgs branch from the flake
  system.stateVersion = "25.11";
}

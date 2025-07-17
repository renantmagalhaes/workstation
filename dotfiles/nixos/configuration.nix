{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/users.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/shell.nix 
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/apps/1password.nix
    ./modules/apps/vivaldi.nix
  ];

  home-manager.users.rtm = import ./home.nix;


  # This now correctly matches the unstable Nixpkgs branch from the flake
  system.stateVersion = "25.05";
}

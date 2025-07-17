{ config, pkgs, ... }:

{
  networking.hostName = "nix-pve-test"; # Define your hostname.

  # Enable networking with NetworkManager (will use DHCP by default).
  networking.networkmanager.enable = true;
}

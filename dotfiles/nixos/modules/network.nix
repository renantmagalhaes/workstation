{ config, pkgs, ... }:

{
  networking.hostName = "workstation"; # Define your hostname.

  # Enable networking with NetworkManager (will use DHCP by default).
  networking.networkmanager.enable = true;
}

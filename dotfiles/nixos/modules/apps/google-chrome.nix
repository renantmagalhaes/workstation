{ config, pkgs, ... }:

{
  # Add Google Chrome to the list of system packages.
  environment.systemPackages = [
    pkgs.google-chrome
  ];
}

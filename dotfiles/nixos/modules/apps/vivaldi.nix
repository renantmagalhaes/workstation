{ config, pkgs, ... }:

{
  # Add Vivaldi to the list of system packages.
  environment.systemPackages = [
    pkgs.vivaldi
  ];
}

{ config, pkgs, inputs, ... }:

{
  # Add Zen Browser from the flake input.
  environment.systemPackages = [
    inputs.zen-browser.packages."${pkgs.system}".default
  ];
}

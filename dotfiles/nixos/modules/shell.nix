# /etc/nixos/modules/shell.nix
{ config, pkgs, ... }:

{
  # This enables Zsh system-wide, making it a valid login shell.
  # It does NOT conflict with Home Manager Zsh configuration.
  programs.zsh.enable = true;
}

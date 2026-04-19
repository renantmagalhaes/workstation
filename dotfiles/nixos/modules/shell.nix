# dotfiles/nixos/modules/shell.nix
{ config, pkgs, ... }:

{
  # This enables Zsh system-wide, making it a valid login shell.
  # It does NOT conflict with Home Manager Zsh configuration.
  programs.zsh.enable = true;

  environment.shellAliases = {
    vpn-up      = "sudo systemctl start wg-quick-vpn.service";
    vpn-down    = "sudo systemctl stop wg-quick-vpn.service";
    vpn-restart = "sudo systemctl restart wg-quick-vpn.service";
    vpn-status  = "sudo wg show";
  };
}

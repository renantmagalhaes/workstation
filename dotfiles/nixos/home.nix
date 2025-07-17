{ config, pkgs, ... }:

{
  # Top-level settings that apply to your entire Home Manager config
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;

  # Import all the individual modules we just created
  imports = [
    ./home-manager/zsh.nix
    ./home-manager/dotfiles.nix
    ./home-manager/packages.nix
  ];
}

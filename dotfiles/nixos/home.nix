{ config, pkgs, inputs, ... }:

{
  # Top-level settings that apply to entire Home Manager config
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  # Import all the individual modules we just created
  imports = [
    ./home-manager/zsh.nix
    ./home-manager/dotfiles.nix
    ./home-manager/packages.nix
    ./home-manager/tmux.nix
    ./home-manager/kitty.nix
    ./home-manager/gtk.nix
    ./home-manager/qt.nix
    ./home-manager/hyprland.nix
    ./home-manager/plasma.nix
    inputs.nix-index-database.homeModules.nix-index
  ];
}

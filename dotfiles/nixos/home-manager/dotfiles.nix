{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  dotfiles = "${home}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # Ensure ~/.dotfiles is a live symlink to the actual git repo, not a nix-store copy.
  home.activation.linkDotfiles = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    run ln -sfn "${home}/GIT-REPOS/workstation/dotfiles" "$HOME/.dotfiles"
  '';

  home.file = {
    ".config/alacritty".source  = link "alacritty";
    ".config/omp".source        = link "zsh/omp";
    
    # KDE / Plasma configuration
    ".config/kglobalshortcutsrc".source = link "kde/shortcuts.kksrc";
    ".config/kvantum".source            = link "kde/kvantum";
    
    ".config/fastfetch".source  = link "fastfetch";
    ".config/guake".source      = link "guake";
    ".config/lsd/config.yaml".source = link "zsh/lsd-config.yaml";
    ".p10k.zsh".source          = link "zsh/p10k.zsh";
  };
}

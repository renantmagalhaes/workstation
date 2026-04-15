{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  dotfiles = "${home}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # Ensure ~/.dotfiles is a live symlink to the actual git repo, not a nix-store copy.
  # Bootstrap (first install only): ln -sfn /path/to/workstation/dotfiles ~/.dotfiles
  home.activation.linkDotfiles = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    run ln -sfn "/home/rtm/GIT-REPOS/workstation/dotfiles" "$HOME/.dotfiles"
  '';

  home.file = {
    ".config/alacritty".source  = link "alacritty";
    ".config/omp".source        = link "zsh/omp";
    ".config/polybar".source    = link "kde/polybar";
    ".config/jgmenu".source     = link "kde/jgmenu";
    ".config/fastfetch".source  = link "fastfetch";
    ".config/guake".source      = link "guake";
    ".config/lsd/config.yaml".source = link "zsh/lsd-config.yaml";
    ".p10k.zsh".source          = link "zsh/p10k.zsh";
    # starship.toml not yet in repo — add dotfiles/zsh/starship/starship.toml to enable
    # ".config/starship.toml".source = link "zsh/starship/starship.toml";
  };
}

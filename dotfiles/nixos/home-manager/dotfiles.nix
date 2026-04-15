{ config, pkgs, lib, inputs, ... }:

{
  # Ensure ~/.dotfiles is a live symlink to the actual git repo, not a nix-store copy.
  # This runs before home-manager writes any files, so other activation steps can rely on it.
  # Bootstrap (first install only): ln -sfn /path/to/workstation/dotfiles ~/.dotfiles
  home.activation.linkDotfiles = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    run ln -sfn "/home/rtm/GIT-REPOS/workstation/dotfiles" "$HOME/.dotfiles"
  '';

  home.file = {
    # Alacritty — full folder so both .toml and .yml variants are available
    ".config/alacritty" = {
      source = "${inputs.dotfiles}/alacritty";
      recursive = true;
    };

    # Oh My Posh themes — symlink the whole folder so all variants are available
    ".config/omp" = {
      source = "${inputs.dotfiles}/zsh/omp";
      recursive = true;
    };

    # Groundwork for Polybar, JGMenu, etc.
    ".config/polybar" = {
      source = "${inputs.dotfiles}/kde/polybar";
      recursive = true;
    };
    ".config/jgmenu" = {
      source = "${inputs.dotfiles}/kde/jgmenu";
      recursive = true;
    };
    ".config/fastfetch" = {
      source = "${inputs.dotfiles}/fastfetch";
      recursive = true;
    };
    ".config/lsd/config.yaml" = {
      source = "${inputs.dotfiles}/zsh/lsd-config.yaml";
    };
    # starship.toml not yet in repo — add dotfiles/zsh/starship/starship.toml to enable
    # ".config/starship.toml" = {
    #   source = "${inputs.dotfiles}/zsh/starship/starship.toml";
    # };
    ".p10k.zsh" = {
      source = "${inputs.dotfiles}/zsh/p10k.zsh";
    };
    # Guake preferences — full folder so all theme variants are available
    ".config/guake" = {
      source = "${inputs.dotfiles}/guake";
      recursive = true;
    };
  };
}

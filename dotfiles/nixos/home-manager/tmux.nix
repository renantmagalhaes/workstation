{ config, pkgs, inputs, ... }:

let
  tmuxDotfiles = "${inputs.dotfiles}/tmux";
in
{
  # This section just enables the tmux program itself.
  programs.tmux = {
    enable = true;
  };

  # This section's only job is to symlink
  home.file = {
    ".tmux.conf" = {
      source = "${tmuxDotfiles}/tmux.conf";
    };
    ".tmux.conf.local" = {
      source = "${tmuxDotfiles}/tmux.conf.local";
    };
    ".tmux/plugins" = {
      source = "${tmuxDotfiles}/plugins";
      recursive = true;
    };
  };
}

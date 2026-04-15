{ config, pkgs, inputs, ... }:

let
  tmuxDotfiles = "${inputs.dotfiles}/tmux";
in
{
  # Install tmux via packages — config comes entirely from the dotfiles symlinks below.
  # Using programs.tmux.enable would write its own tmux.conf and conflict with home.file.
  home.packages = [ pkgs.tmux ];

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

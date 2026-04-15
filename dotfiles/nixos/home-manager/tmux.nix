{ config, pkgs, ... }:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/${path}";
in
{
  home.packages = [ pkgs.tmux ];

  home.file = {
    ".tmux.conf".source       = link "tmux/tmux.conf";
    ".tmux.conf.local".source = link "tmux/tmux.conf.local";
    ".tmux/plugins".source    = link "tmux/plugins";
  };
}

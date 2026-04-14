{ config, pkgs, inputs, ... }:

{
  programs.kitty = {
    enable = true;
    # We will use your existing configuration directory by symlinking it
  };

  # Symlink the entire kitty dotfiles directory from your repository
  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${inputs.dotfiles}/kitty";
    recursive = true;
  };
}

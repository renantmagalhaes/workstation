{ config, pkgs, inputs, ... }:

{
  programs.kitty = {
    enable = true;
    # We will use your existing configuration directory by symlinking it
  };

  # Symlink the entire kitty config folder — live link so edits take effect immediately
  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/kitty";
  };
}

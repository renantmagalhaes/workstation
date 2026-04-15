{ config, pkgs, ... }:

{
  # Install kitty via packages — config comes entirely from the dotfiles symlink below.
  # Using programs.kitty.enable would write its own kitty.conf and conflict with the symlink.
  home.packages = [ pkgs.kitty ];

  # Live symlink so kitty config edits in ~/.dotfiles take effect without rebuilding.
  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/kitty";
  };
}

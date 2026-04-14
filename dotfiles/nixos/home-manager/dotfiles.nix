{ config, pkgs, inputs, ... }:

{
  home.file = {
    # Symlink the Oh My Posh theme from the dotfiles *flake input*
    ".config/omp/oh-my-posh-minimal.yaml" = {
      source = "${inputs.dotfiles}/zsh/omp/oh-my-posh-minimal.yaml";
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
    ".config/sxhkd/sxhkdrc" = {
      source = "${inputs.dotfiles}/kde/sxhkd/sxhkdrc";
    };
    ".config/fastfetch" = {
      source = "${inputs.dotfiles}/fastfetch";
      recursive = true;
    };
    # Guake preferences link (groundwork)
    ".config/guake/guake-settings" = {
      source = "${inputs.dotfiles}/utils/guake/rtm-guake-setting";
    };
  };
}

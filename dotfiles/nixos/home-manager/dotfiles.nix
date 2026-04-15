{ config, pkgs, inputs, ... }:

{
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
    # Compatibility link for legacy scripts
    ".zsh" = {
      source = "${inputs.dotfiles}/zsh/zsh-files";
      recursive = true;
    };
    # The crucial legacy link many scripts depend on
    ".dotfiles" = {
      source = "${inputs.dotfiles}";
    };
    # Guake preferences — full folder so all theme variants are available
    ".config/guake" = {
      source = "${inputs.dotfiles}/guake";
      recursive = true;
    };
  };
}

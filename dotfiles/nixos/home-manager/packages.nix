{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    oh-my-posh
    lazygit
    neovim
    zoxide
    fastfetch
    fzf
    bat
    lsd
    alacritty

    # Python tools
    btop
    pylint
    python3Packages.virtualenv
    python3Packages.virtualenvwrapper
  ];
}

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
  ];
}

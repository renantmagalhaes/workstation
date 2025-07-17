{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    oh-my-posh
    lazygit
    neovim
  ];
}

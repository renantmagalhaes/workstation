{ config, pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    maple-mono.NF
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    powerline-fonts
    cantarell-fonts
  ];

  environment.systemPackages = with pkgs; [
    # Cursors
    capitaine-cursors
    apple-cursor
    comixcursors
    afterglow-cursors-recolored

    # GTK / Qt Themes
    materia-theme
    fluent-gtk-theme
    dracula-theme
    dracula-qt5-theme

    # Icon Themes
    papirus-icon-theme
    tela-icon-theme
    tela-circle-icon-theme
    kdePackages.breeze-icons
    dracula-icon-theme
  ];
}

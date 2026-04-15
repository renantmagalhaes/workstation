{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  dotfiles = "${home}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.packages = with pkgs; [
    graphite-gtk-theme
    tela-circle-icon-theme
    fluent-cursor-theme
    wlogout
    swaybg
    yad
    brightnessctl
    playerctl
  ];

  # Symlinks to dotfiles repo
  home.file = {
    ".config/hypr".source = link "hyprland/hypr";
    ".config/waybar".source = link "hyprland/waybar";
    ".config/mako".source = link "mako";
    ".config/rofi".source = link "rofi";
    ".config/jgmenu".source = link "hyprland/hypr/jgmenu";
    ".config/wlogout".source = link "hyprland/waybar/extra/wlogout";
  };

  # GTK Theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme;
    };
    iconTheme = {
      name = "Tela-circle-purple-light";
      package = pkgs.tela-circle-icon-theme;
    };
    cursorTheme = {
      name = "Fluent-dark-cursors";
      package = pkgs.fluent-cursor-theme;
      size = 24;
    };
  };

  # QS-Launcher Bootstrap
  # Handles the git clone described in the original install script
  home.activation.setupQSLauncher = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    QS_DIR="$HOME/.QS-Launcher"
    if [ ! -d "$QS_DIR/.git" ]; then
      run rm -rf "$QS_DIR"
      run ${pkgs.git}/bin/git clone --depth 1 git@github.com:renantmagalhaes/QS-Launcher.git "$QS_DIR"
    fi
  '';
}

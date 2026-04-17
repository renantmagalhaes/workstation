{ config, pkgs, ... }:

{
  # System-wide cursor (covers non-GTK apps: Electron, terminals, etc.)
  home.pointerCursor = {
    gtk.enable = true;
    name = "Breeze_Light";
    package = pkgs.kdePackages.breeze;
    size = 24;
  };

  # GTK theme
  gtk = {
    enable = true;

    colorScheme = "dark";

    theme = {
      name = "catppuccin-macchiato-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "standard";
        variant = "macchiato";
      };
    };
    iconTheme = {
      name = "Tela-circle-dracula";
      package = pkgs.tela-circle-icon-theme.override {
        circularFolder = true;
        colorVariants = [ "dracula" ];
      };
    };
    cursorTheme = {
      name = "Breeze_Light";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };

    gtk3 = {
      colorScheme = "dark";
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      colorScheme = "dark";
      theme = config.gtk.theme;
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
  };

  # Forces GTK to use the portal for settings — needed on non-GNOME compositors
  home.sessionVariables.GTK_USE_PORTAL = "1";

  # Global dark preference — read by GTK4, GNOME, and portal-aware apps
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme    = "catppuccin-macchiato-mauve-standard";
      icon-theme   = "Tela-circle-dracula";
      cursor-theme = "Breeze_Light";
      cursor-size  = 24;
    };
  };
}

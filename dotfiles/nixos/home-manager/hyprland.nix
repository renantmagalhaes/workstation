{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  dotfiles = "${home}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.packages = with pkgs; [
    catppuccin-gtk
    papirus-icon-theme
    bibata-cursors
    wlogout
    swaybg
    yad
    brightnessctl
    playerctl
    xdg-desktop-portal-gtk
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

  # System-wide cursor (covers non-GTK apps: Electron, terminals, etc.)
  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # GTK Theme configuration
  gtk = {
    enable = true;

    colorScheme = "dark";

    theme = {
      name = "catppuccin-macchiato-pink-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "standard";
        variant = "macchiato";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
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

  # Qt follows GTK theme
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # Forces GTK to use the portal for settings — needed on non-GNOME compositors
  home.sessionVariables.GTK_USE_PORTAL = "1";

  # Global dark preference read by GTK4 and portal-aware apps
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Rofi desktop entries (replaces the imperative creation in scripts/rofi.sh)
  xdg.desktopEntries = {
    kill-process = {
      name = "Kill Process";
      exec = "${home}/.config/rofi/scripts/kill.sh";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "System" ];
    };
    power-menu = {
      name = "Power Menu";
      exec = "${home}/.config/rofi/scripts/power-menu.sh";
      icon = "system-shutdown";
      terminal = false;
      categories = [ "System" ];
    };
    power-menu-shutdown = {
      name = "Shutdown";
      exec = "${home}/.config/rofi/scripts/rofi-shutdown.sh";
      icon = "system-shutdown";
      terminal = false;
      categories = [ "System" ];
    };
    power-menu-restart = {
      name = "Restart";
      exec = "${home}/.config/rofi/scripts/rofi-restart.sh";
      icon = "system-reboot";
      terminal = false;
      categories = [ "System" ];
    };
    power-menu-logout = {
      name = "Logout";
      exec = "${home}/.config/rofi/scripts/rofi-logout.sh";
      icon = "system-log-out";
      terminal = false;
      categories = [ "System" ];
    };
  };

  # QS-Launcher Bootstrap
  # Handles the git clone described in the original install script
  home.activation.setupQSLauncher = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    QS_DIR="$HOME/.QS-Launcher"
    if [ ! -d "$QS_DIR/.git" ]; then
      run rm -rf "$QS_DIR"
      run ${pkgs.git}/bin/git clone --depth 1 https://github.com/renantmagalhaes/QS-Launcher.git "$QS_DIR"
    fi
  '';
}

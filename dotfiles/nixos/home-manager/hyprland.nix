{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  dotfiles = "${home}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.packages = with pkgs; [
    wlogout
    swaybg
    yad
    brightnessctl
    playerctl
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  # Rofi wrapper shadowing the real binary via ~/.local/bin (which is earlier in PATH).
  # Passes --normal-window on GNOME since it doesn't support the layer shell protocol.
  home.file.".local/bin/rofi" = {
    text = ''
      #!/bin/sh
      if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        exec ${pkgs.rofi}/bin/rofi --normal-window "$@"
      else
        exec ${pkgs.rofi}/bin/rofi "$@"
      fi
    '';
    executable = true;
  };

  # Symlinks to dotfiles repo
  home.file = {
    ".config/hypr".source = link "hyprland/hypr";
    ".config/waybar".source = link "hyprland/waybar";
    ".config/mako".source = link "mako";
    ".config/rofi".source = link "rofi";
    ".config/jgmenu".source = link "hyprland/hypr/jgmenu";
    ".config/wlogout".source = link "hyprland/waybar/extra/wlogout";
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

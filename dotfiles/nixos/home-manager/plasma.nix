{ config, pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    # Global Shortcuts
    shortcuts = {
      "net.local.1password.desktop" = {
        "_launch" = "Ctrl+Shift+Space";
      };
      "net.local.flameshot.desktop" = {
        "_launch" = "Print";
      };
      "org.kde.krunner.desktop" = {
        "_launch" = [ "Meta" "Alt+F2" "Search" ];
      };
      "org.kde.dolphin.desktop" = {
        "_launch" = "Meta+E";
      };
      "org.kde.plasma-systemmonitor.desktop" = {
        "_launch" = "Meta+Esc";
      };
      "kitty.desktop" = {
        "_launch" = "Ctrl+Alt+T";
      };
      "kwin" = {
        "Window Close" = "Meta+Q; Alt+F4";
        "Overview" = "Meta+W";
        "Expose" = "Meta+F9";
        "Grid View" = "Meta+G";
        "Window Maximize" = "Meta+Up";
        "Window Minimize" = "Meta+Down";
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
      };
    };

    # You can also manage your desktop settings here
    configFile = {
      "kwinrc"."Desktops"."Number" = 5;
      "kwinrc"."Desktops"."Rows" = 1;
    };
  };
}

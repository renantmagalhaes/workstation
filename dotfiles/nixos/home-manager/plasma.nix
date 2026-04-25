{ config, pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    # Global Shortcuts
    shortcuts = {
      # For Plasma 6, services usually need the 'services/' prefix
      "services/1password.desktop"."_launch" = "Ctrl+Shift+Space";
      "services/org.flameshot.Flameshot.desktop"."_launch" = "Print";
      "services/org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "services/kitty.desktop"."_launch" = "Ctrl+Alt+T";
      
      "org.kde.krunner.desktop" = {
        "_launch" = [ "Meta" "Alt+F2" "Search" ];
      };
      "org.kde.plasma-systemmonitor.desktop" = {
        "_launch" = "Meta+Esc";
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

    # As a secondary way to ensure they appear in the UI
    hotkeys.commands = {
      "launch-1password" = {
        name = "1Password";
        key = "Ctrl+Shift+Space";
        command = "1password";
      };
      "launch-flameshot" = {
        name = "Flameshot";
        key = "Print";
        command = "flameshot gui";
      };
    };

    # Desktop settings
    configFile = {
      "kwinrc"."Desktops"."Number" = 5;
      "kwinrc"."Desktops"."Rows" = 1;
    };
  };
}

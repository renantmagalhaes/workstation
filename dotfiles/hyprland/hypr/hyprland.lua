-- Main Hyprland Lua config
-- https://wiki.hypr.land/Configuring/Start/

-- Global program definitions (accessible in all required modules)
terminal    = "kitty"
fileManager = "nautilus"
menu        = "~/.QS-Launcher/spotlight"
rofiMenu    = "~/.config/rofi/scripts/rofi-menu.sh"
browser     = "vivaldi-stable"
mainMod     = "SUPER"

require("envs")
require("monitors")
require("input")
require("theme")
require("startup")
require("keybinds")
require("workspaces")

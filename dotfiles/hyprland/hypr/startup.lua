-- Startup applications (exec-once equivalents)

hl.on("hyprland.start", function()
    -- Force monitor/workspace layout on launch
    hl.exec_cmd("~/.config/hypr/scripts/wsync.sh 1")

    -- Status bars
    hl.exec_cmd("waybar -c ~/.dotfiles/hyprland/waybar/config.jsonc -s ~/.dotfiles/hyprland/waybar/style.css")
    hl.exec_cmd("waybar -c ~/.dotfiles/hyprland/waybar/trigger_config.jsonc -s ~/.dotfiles/hyprland/waybar/trigger_style.css")

    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon")

    -- Authentication agent
    hl.exec_cmd("/usr/libexec/polkit-mate-authentication-agent-1 &")

    -- Idle daemon (auto-lock / suspend)
    hl.exec_cmd("hypridle")

    -- System tray
    hl.exec_cmd("nm-applet &")

    -- Notification daemon
    hl.exec_cmd("mako &")

    -- KDE Connect (phone integration)
    hl.exec_cmd("kdeconnectd &")
    hl.exec_cmd("kdeconnect-indicator &")

    -- Vivaldi: remove singleton lock files to allow launch
    hl.exec_cmd("rm -rf ~/.config/vivaldi/Singleton* &")

    -- Clipboard manager (text + image)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Password manager (silent tray)
    hl.exec_cmd("/usr/bin/1password --silent &")

    -- Kitty pre-launched into magic (special) workspace
    hl.exec_cmd("~/.config/hypr/scripts/launch-kitty-magic.sh")

    -- Mouse side-button action handler
    hl.exec_cmd("~/.dotfiles/hyprland/hypr/scripts/mouse_actions.py &")

    -- Service watchdog (restart crashed processes)
    hl.exec_cmd("~/.config/hypr/scripts/watchdog.sh &")

    -- Custom spotlight launcher
    hl.exec_cmd("~/.QS-Launcher/spotlight &")

    -- Waybar indicator watcher (instant updates)
    hl.exec_cmd("~/.dotfiles/hyprland/waybar/scripts/waybar_indicator_watcher.sh &")

    -- Hyprswitch (window switcher overlay)
    hl.exec_cmd("hyprswitch init --show-title --size-factor 5.5 --workspaces-per-row 5 &")
end)

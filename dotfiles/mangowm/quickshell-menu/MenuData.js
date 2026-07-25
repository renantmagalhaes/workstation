.pragma library

// Menu tree for the mango right-click context menu. Each leaf's `command`
// is executed verbatim as `bash -c "<command>"`, so $HOME etc. are expanded
// by bash at run time using the launching shell's environment - no path
// resolution needed here. Ported 1:1 from mango-menu-rofi.sh's case arms.

var streamingMenu = [
    { label: "Strem.IO", icon: "stremio", command: "flatpak run com.stremio.Stremio" },
    { label: "Plex", icon: "plex", command: "flatpak run tv.plex.PlexDesktop" }
];

var wmMenu = [
    {
        label: "Restart Waybar",
        icon: "xfce4-systray",
        command: `killall waybar; waybar -c "$HOME/.dotfiles/mangowm/waybar/config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/style.css" & waybar -c "$HOME/.dotfiles/mangowm/waybar/trigger_config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/trigger_style.css" &`
    },
    {
        label: "Reload MangoWM",
        icon: "preferences-desktop",
        command: `mmsg dispatch reload_config && notify-send -i preferences-desktop "MangoWM" "Successfully reloaded MangoWM"`
    },
    {
        label: "Restart Mako",
        icon: "preferences-system-notifications",
        command: `killall mako; mako &`
    }
];

var extraMenu = [
    {
        label: "Mouse Battery Level",
        icon: "input-mouse",
        command: `"$HOME/.dotfiles/mangowm/scripts/mouse-battery.sh"`
    }
];

var menu = [
    {
        label: "Applications",
        icon: "applications-all",
        command: `rofi -show drun -show-icons -theme "$HOME/.config/rofi/scripts/launchers/type-7/style-5.rasi"`
    },
    { label: "Terminal", icon: "Terminal", command: "kitty" },
    { label: "File Explorer", icon: "folder", command: "nautilus" },
    { label: "Browser", icon: "vivaldi", command: "/usr/bin/vivaldi" },
    { label: "Browser (Incognito)", icon: "abrowser", command: "/usr/bin/vivaldi --incognito" },
    { label: "Streaming", icon: "camera-video", submenu: streamingMenu },
    { label: "WM Options", icon: "xfce4-systray", submenu: wmMenu },
    { label: "Extra Options", icon: "list-add", submenu: extraMenu },
    {
        label: "Find Window Class",
        icon: "window_list",
        command: `class=$(mmsg get focusing-client | jq -r '.appid // empty'); if [ -n "$class" ]; then echo -n "$class" | wl-copy; notify-send -i window_list "Find Window Class" "Window class $class copied to clipboard"; else notify-send -i window_list "Find Window Class" "No focused window found"; fi`
    },
    {
        label: "Find Window Class (Click)",
        icon: "window_list",
        command: `"$HOME/.dotfiles/mangowm/scripts/get-window-class-by-click.py"`
    },
    { label: "Change Wallpaper", icon: "nitrogen", command: "waypaper" },
    { label: "Appearance", icon: "mtpaint", command: "lxappearance" },
    {
        label: "Randomize Wallpaper",
        icon: "phototonic",
        command: `awww img "$(find "$HOME/Pictures/wallpapers" -type f \\( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \\) | shuf -n 1)"`
    },
    { label: "Lock", icon: "system-lock-screen", command: `"$HOME/.dotfiles/mangowm/scripts/lock.sh"` },
    { label: "Logout", icon: "system-log-out", command: "wlogout" },
    { label: "Exit", icon: "system-shutdown", command: "wlogout" }
];

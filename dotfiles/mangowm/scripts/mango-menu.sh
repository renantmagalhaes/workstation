#!/usr/bin/env bash
# Right-click context menu for the waybar triggers, replacing jgmenu.
#
# jgmenu is an X11 app running under XWayland, which only gets pointer
# updates while the cursor is over an XWayland surface -- so its idea of
# "where the pointer is" goes stale and the menu opens in random places,
# including the wrong monitor. rofi (this build) is a native Wayland
# client with layer-shell support, so it gets accurate pointer/monitor
# info straight from the compositor.
#
# rofi's `-m -3` (position at mouse) turned out to only pick the right
# monitor -- it always anchors top-left on that monitor and fully ignores
# `-location`. Since both triggers are full-width edge strips (top/bottom),
# we get the same "appears where you clicked" result more reliably by
# asking mango directly for which monitor the pointer is on and anchoring
# rofi to that monitor's matching corner ourselves.

edge="${1:-bottom}" # "bottom" for the bottom trigger bar, "top" for the top one
theme="$HOME/.dotfiles/mangowm/rofi/context-menu.rasi"

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

monitor=$(mmsg get cursorpos 2>/dev/null | jq -r '.monitor // empty' 2>/dev/null)
location=1 # top-left
[ "$edge" = "bottom" ] && location=7 # bottom-left

rofi_args=(-dmenu -location "$location" -show-icons -theme "$theme" -no-custom)
[ -n "$monitor" ] && rofi_args+=(-m "$monitor")

# args: prompt "Label|icon" ...
show_menu() {
    local prompt="$1"
    shift
    local entry
    for entry in "$@"; do
        printf '%s\0icon\x1f%s\n' "${entry%%|*}" "${entry#*|}"
    done | rofi "${rofi_args[@]}" -p "$prompt"
}

streaming_menu() {
    local sel
    sel=$(show_menu "Streaming" \
        "← Back|go-previous" \
        "Strem.IO|stremio" \
        "Plex|plex")
    case "$sel" in
    "Strem.IO") flatpak run com.stremio.Stremio & ;;
    "Plex") flatpak run tv.plex.PlexDesktop & ;;
    "← Back") main_menu ;;
    esac
}

wm_menu() {
    local sel
    sel=$(show_menu "WM Options" \
        "← Back|go-previous" \
        "Restart Waybar|xfce4-systray" \
        "Reload MangoWM|preferences-desktop" \
        "Restart Mako|preferences-system-notifications")
    case "$sel" in
    "Restart Waybar")
        killall waybar
        waybar -c "$HOME/.dotfiles/mangowm/waybar/config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/style.css" &
        waybar -c "$HOME/.dotfiles/mangowm/waybar/trigger_config.jsonc" -s "$HOME/.dotfiles/mangowm/waybar/trigger_style.css" &
        ;;
    "Reload MangoWM")
        mmsg dispatch reload_config
        notify-send -i preferences-desktop "MangoWM" "Successfully reloaded MangoWM"
        ;;
    "Restart Mako")
        killall mako
        mako &
        ;;
    "← Back") main_menu ;;
    esac
}

extra_menu() {
    local sel
    sel=$(show_menu "Extra Options" \
        "← Back|go-previous" \
        "Mouse Battery Level|input-mouse")
    case "$sel" in
    "Mouse Battery Level") "$HOME/.dotfiles/mangowm/scripts/mouse-battery.sh" & ;;
    "← Back") main_menu ;;
    esac
}

main_menu() {
    local sel
    sel=$(show_menu "" \
        "Applications|applications-all" \
        "Terminal|Terminal" \
        "File Explorer|folder" \
        "Browser|vivaldi" \
        "Browser (Incognito)|abrowser" \
        "Streaming ▸|camera-video" \
        "WM Options ▸|xfce4-systray" \
        "Extra Options ▸|list-add" \
        "Find Window Class|window_list" \
        "Find Window Class (Click)|window_list" \
        "Change Wallpaper|nitrogen" \
        "Appearance|mtpaint" \
        "Randomize Wallpaper|phototonic" \
        "Lock|system-lock-screen" \
        "Logout|system-log-out" \
        "Exit|system-shutdown")

    case "$sel" in
    "Applications") rofi -show drun -show-icons -theme "$HOME/.config/rofi/scripts/launchers/type-7/style-5.rasi" & ;;
    "Terminal") kitty & ;;
    "File Explorer") nautilus & ;;
    "Browser") /usr/bin/vivaldi & ;;
    "Browser (Incognito)") /usr/bin/vivaldi --incognito & ;;
    "Streaming ▸") streaming_menu ;;
    "WM Options ▸") wm_menu ;;
    "Extra Options ▸") extra_menu ;;
    "Find Window Class")
        class=$(mmsg get focusing-client | jq -r '.appid // empty')
        if [ -n "$class" ]; then
            echo -n "$class" | wl-copy
            notify-send -i window_list "Find Window Class" "Window class $class copied to clipboard"
        else
            notify-send -i window_list "Find Window Class" "No focused window found"
        fi
        ;;
    "Find Window Class (Click)") "$HOME/.dotfiles/mangowm/scripts/get-window-class-by-click.py" & ;;
    "Change Wallpaper") waypaper & ;;
    "Appearance") lxappearance & ;;
    "Randomize Wallpaper")
        awww img "$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)" &
        ;;
    "Lock") "$HOME/.dotfiles/mangowm/scripts/lock.sh" ;;
    "Logout") wlogout & ;;
    "Exit") wlogout & ;;
    esac
}

main_menu

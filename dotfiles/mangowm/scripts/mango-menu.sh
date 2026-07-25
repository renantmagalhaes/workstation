#!/usr/bin/env bash
# Right-click context menu for the waybar triggers, replacing jgmenu.
#
# jgmenu is an X11 app running under XWayland, which only gets pointer
# updates while the cursor is over an XWayland surface -- so its idea of
# "where the pointer is" goes stale and the menu opens in random places,
# including the wrong monitor. Native Wayland clients with layer-shell
# support get accurate pointer/monitor info straight from the compositor.
#
# Positioning turned out to only reliably pick the right monitor, always
# anchoring to a corner of it -- literal "at the mouse" placement wasn't
# reliable. Since both triggers are full-width edge strips (top/bottom), we
# get the same "appears where you clicked" result more reliably by asking
# mango directly for which monitor the pointer is on and anchoring to that
# monitor's matching corner ourselves.
#
# Two backends are available -- flip MENU_BACKEND below to compare them:
#   quickshell - native tree menu with real flyout submenus (qs/quickshell-menu/)
#   rofi       - the original flat rofi menu, kept as mango-menu-rofi.sh

MENU_BACKEND="quickshell"

# mango/waybar don't source shell rc files, so nix profile bin dirs (where
# things like waypaper live) are missing from PATH unless we add them here.
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

edge="${1:-bottom}" # "bottom" for the bottom trigger bar, "top" for the top one

if [ -z "$MANGO_INSTANCE_SIGNATURE" ] || [ ! -S "$MANGO_INSTANCE_SIGNATURE" ]; then
    mango_pid=$(pgrep -u "$USER" -x mango | head -n 1)
    if [ -n "$mango_pid" ]; then
        export MANGO_INSTANCE_SIGNATURE="/run/user/$(id -u)/mango-${mango_pid}.sock"
    fi
fi

case "$MENU_BACKEND" in
rofi)
    exec "$HOME/.dotfiles/mangowm/scripts/mango-menu-rofi.sh" "$edge"
    ;;
*)
    monitor=$(mmsg get cursorpos 2>/dev/null | jq -r '.monitor // empty' 2>/dev/null)
    export MENU_EDGE="$edge"
    export MENU_MONITOR="$monitor"
    exec quickshell -n -p "$HOME/.dotfiles/mangowm/quickshell-menu/shell.qml"
    ;;
esac

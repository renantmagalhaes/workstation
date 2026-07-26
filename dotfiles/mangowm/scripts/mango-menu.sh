#!/usr/bin/env bash
# Right-click context menu for the waybar triggers, replacing jgmenu.
#
# jgmenu is an X11 app running under XWayland, which only gets pointer
# updates while the cursor is over an XWayland surface -- so its idea of
# "where the pointer is" goes stale and the menu opens in random places,
# including the wrong monitor. Native Wayland clients with layer-shell
# support get accurate pointer/monitor info straight from the compositor.
#
# rofi's own positioning only reliably picks the right monitor, always
# anchoring to a corner of it -- literal "at the mouse" placement isn't
# reliable there (see mango-menu-rofi.sh). The quickshell backend doesn't
# have that limitation, so it positions itself at the actual cursor
# coordinates (clamped to stay on-screen), which is what makes it feel like
# a real right-click menu instead of an edge-anchored popup.
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
    cursor=$(mmsg get cursorpos 2>/dev/null)
    monitor=$(printf '%s' "$cursor" | jq -r '.monitor // empty' 2>/dev/null)
    cursor_x=$(printf '%s' "$cursor" | jq -r '.x // 0' 2>/dev/null)
    cursor_y=$(printf '%s' "$cursor" | jq -r '.y // 0' 2>/dev/null)

    # mmsg reports cursor position in global (all-monitors) coordinates, but
    # the menu window is local to its own monitor, so subtract that
    # monitor's origin to get where the cursor is within it.
    if [ -n "$monitor" ]; then
        geom=$(mmsg get monitor "$monitor" 2>/dev/null)
        mon_x=$(printf '%s' "$geom" | jq -r '.x // 0' 2>/dev/null)
        mon_y=$(printf '%s' "$geom" | jq -r '.y // 0' 2>/dev/null)
    else
        mon_x=0
        mon_y=0
    fi

    # mmsg can report fractional pointer coordinates (fractional scaling /
    # sub-pixel motion), which bash's integer-only `$(( ))` can't parse at
    # all -- it throws a fatal syntax error and kills the script before the
    # menu ever launches. awk handles floats fine and we don't need
    # sub-pixel precision for menu placement anyway.
    MENU_CURSOR_X=$(awk "BEGIN { printf \"%d\", ($cursor_x) - ($mon_x) }")
    MENU_CURSOR_Y=$(awk "BEGIN { printf \"%d\", ($cursor_y) - ($mon_y) }")
    export MENU_EDGE="$edge" MENU_MONITOR="$monitor" MENU_CURSOR_X MENU_CURSOR_Y
    exec quickshell -n -p "$HOME/.dotfiles/mangowm/quickshell-menu/shell.qml"
    ;;
esac

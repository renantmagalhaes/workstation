-- Environment variables

-- Cursor
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME",   "Breeze_Light")
hl.env("HYPRCURSOR_THEME","Breeze_Light")

-- Wayland forcing
hl.env("GDK_BACKEND",    "wayland,x11,*")
hl.env("QT_QPA_PLATFORM","wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND","1")
hl.env("OZONE_PLATFORM",  "wayland")
hl.env("XDG_SESSION_TYPE","wayland")

-- Desktop identity
hl.env("XDG_CURRENT_DESKTOP","Hyprland")
hl.env("XDG_SESSION_DESKTOP","Hyprland")

-- Electron compatibility
hl.env("ELECTRON_OZONE_PLATFORM_HINT","auto")

-- Global dark mode / theming
hl.env("GTK_THEME",                       "Graphite-Dark")
hl.env("GTK_APPLICATION_PREFER_DARK_THEME","1")
hl.env("QT_QPA_PLATFORMTHEME",            "Kvantum")
hl.env("QT_STYLE_OVERRIDE",              "kvantum")

-- XCompose support
hl.env("XCOMPOSEFILE","~/.XCompose")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    ecosystem = {
        no_update_news = true,
    },
})

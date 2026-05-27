-- Window rules, layer rules, and workspace configuration

-----------------------
---- WINDOW RULES ----
-----------------------

hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "nautilus-opacity",
    match = { class = "org.gnome.Nautilus.*$" },
    -- Two values: { active_opacity, inactive_opacity }
    opacity = "0.97 0.9",
})

hl.window_rule({
    name  = "jgmenu-pin",
    match = { class = "^(jgmenu|Jgmenu)$" },
    pin          = true,
    float        = true,
    stay_focused = true,
})

hl.window_rule({
    name  = "windscribe-float",
    match = { class = "Windscribe" },
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "flameshot-fix",
    match = { class = "flameshot" },
    float            = true,
    pin              = true,
    move             = "0 0",
    size             = "5120 1440",
    fullscreen_state = "0 3",
    no_anim          = true,
})

hl.window_rule({
    name  = "copyq-float",
    -- Escaped dots so the regex matches literal dots in the class name
    match = { class = "^(com\\.github\\.hluk\\.copyq|copyq)$" },
    float  = true,
    size   = "800 600",
    center = true,
})

-----------------------
---- LAYER RULES ----
-----------------------

hl.layer_rule({
    name  = "blur-notifications",
    match = { namespace = "notifications" },
    blur         = true,
    ignore_alpha = 0.10,
})

hl.layer_rule({
    name  = "blur-mako",
    match = { namespace = "mako" },
    blur         = true,
    ignore_alpha = 0.10,
})

hl.layer_rule({
    name  = "blur-waybar",
    match = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.05,
})

hl.layer_rule({
    name  = "blur-rofi",
    match = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.15,
})

-----------------------
---- WORKSPACE CONFIG ----
-----------------------

-- Monitor 1 (DP-1): workspaces 1-5
hl.workspace_rule({ workspace = "1",  monitor = "DP-1",     persistent = true, default = true })
hl.workspace_rule({ workspace = "2",  monitor = "DP-1",     persistent = true })
hl.workspace_rule({ workspace = "3",  monitor = "DP-1",     persistent = true })
hl.workspace_rule({ workspace = "4",  monitor = "DP-1",     persistent = true })
hl.workspace_rule({ workspace = "5",  monitor = "DP-1",     persistent = true })

-- Monitor 2 (HDMI-A-1): workspaces 6-10
hl.workspace_rule({ workspace = "6",  monitor = "HDMI-A-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "7",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "8",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "9",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1", persistent = true })

-- Special workspace: kitty terminal scratchpad
hl.workspace_rule({
    workspace = "special:kitty",
    gaps_out  = 50,
    no_border = true,
})

-- Apply opacity to windows running in the special kitty workspace
hl.window_rule({
    match = { workspace = "special:kitty" },
    opacity = "0.9",
})

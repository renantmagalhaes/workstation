-- Look and feel
-- https://wiki.hypr.land/Configuring/Variables/

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 15,

        border_size = 2,

        col = {
            -- Minty soft green (rgba decimal 120,255,180 → hex 78ffb4)
            active_border   = "rgba(78ffb4ff)",
            -- Gray (rgba decimal 100,100,100 → hex 646464)
            inactive_border = "rgba(646464ff)",
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "scrolling",
    },

    decoration = {
        dim_special = 0.2,
        rounding    = 10,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
        },

        blur = {
            enabled            = true,
            size               = 6,
            passes             = 3,
            new_optimizations  = true,
            ignore_opacity     = true,
            xray               = false,
            noise              = 0.02,
            contrast           = 1.6,
            brightness         = 1,
            vibrancy           = 0.4,
            vibrancy_darkness  = 0.4,
            popups             = true,
            popups_ignorealpha = 0.20,
            special            = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        pseudotile     = true,
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
        column_width             = 0.5,
        focus_fit_method         = 1,
        follow_focus             = true,
        follow_min_visible       = 0.4,
        explicit_column_widths   = { 0.333, 0.5, 0.667, 1.0 },
        direction                = "right",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- Bezier curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}     } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}     } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}        } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}     } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}      } })
hl.curve("overshot",       { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}   } })
hl.curve("smoothOut",      { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })
hl.curve("reap",           { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1}    } })

-- Animations (KDE-style bouncy windows, smooth workspaces)
hl.animation({ leaf = "global",           enabled = true, speed = 10,   bezier = "default"      })
hl.animation({ leaf = "border",           enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",          enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 10,   bezier = "overshot",     style = "popin 5%"          })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 10,   bezier = "reap",         style = "popin 5%"          })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 3,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 5,    bezier = "almostLinear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 5,    bezier = "almostLinear" })
hl.animation({ leaf = "layers",           enabled = true, speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 2,    bezier = "easeOutQuint", style = "fade"              })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 2,    bezier = "linear",       style = "fade"              })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5,    bezier = "easeOutQuint", style = "slide"             })
hl.animation({ leaf = "workspacesIn",     enabled = true, speed = 5,    bezier = "easeOutQuint", style = "slide"             })
hl.animation({ leaf = "workspacesOut",    enabled = true, speed = 5,    bezier = "easeOutQuint", style = "slide"             })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5,    bezier = "easeOutQuint", style = "slidefadevert -50%" })

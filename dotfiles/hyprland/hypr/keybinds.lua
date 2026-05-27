-- Keybindings
-- mainMod and program vars defined globally in hyprland.lua

local clipCmd = [[bash -c "~/.config/hypr/scripts/cliphist-rofi-img | rofi -dmenu -show-icons -theme ~/.config/rofi/cliphist.rasi -matching fuzzy -i | awk '{print $1}' | xargs -r ~/.config/hypr/scripts/cliphist-rofi-img"]]

-----------------------
---- BASIC ACTIONS ----
-----------------------

hl.bind("CTRL + ALT + T",          hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + SHIFT + SPACE",    hl.dsp.exec_cmd("1password --quick-access &"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind("ALT + SPACE",             hl.dsp.exec_cmd(rofiMenu))
hl.bind("SUPER + SUPER_L",         hl.dsp.exec_cmd(menu), { release = true })

-----------------------
---- WINDOW MANAGEMENT ----
-----------------------

hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M",         hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))

-----------------------
---- SYSTEM ACTIONS ----
-----------------------

hl.bind(mainMod .. " + ALT + escape", hl.dsp.exit())
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd("~/.dotfiles/hyprland/hypr/scripts/lock.sh"))
hl.bind("CTRL + SUPER + C",           hl.dsp.exec_cmd("~/.dotfiles/utils/inzone_reset_usb_pkexec.sh"))

-----------------------
---- SCREENSHOT ----
-----------------------

hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"))

-----------------------
---- CLIPBOARD ----
-----------------------

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipCmd))
hl.bind("ALT + V",          hl.dsp.exec_cmd(clipCmd))

-----------------------
---- SCROLLING LAYOUT FOCUS ----
-----------------------

hl.bind(mainMod .. " + left",  hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + up",    hl.dsp.layout("focus u"))
hl.bind(mainMod .. " + down",  hl.dsp.layout("focus d"))

hl.bind("ALT + mouse_down",   hl.dsp.layout("focus l"))
hl.bind("ALT + mouse_up",     hl.dsp.layout("focus r"))
hl.bind("SHIFT + mouse_down", hl.dsp.layout("focus l"))
hl.bind("SHIFT + mouse_up",   hl.dsp.layout("focus r"))

-----------------------
---- SCROLLING LAYOUT MANAGEMENT ----
-----------------------

hl.bind(mainMod .. " + period",         hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma",          hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + P",              hl.dsp.layout("promote"))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + R",              hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + F",              hl.dsp.layout("fit active"))

-----------------------
---- MOUSE BINDINGS ----
-----------------------

-- Thumb button → rofi mouse menu
hl.bind("mouse:277", hl.dsp.exec_cmd("~/.config/rofi/scripts/rofi-mouse-menu.sh"))

-- Move/resize windows with mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------------------
---- WORKSPACE PAIR NAVIGATION (dual monitor) ----
-----------------------

hl.bind("CTRL + SUPER + right", hl.dsp.exec_cmd("~/.config/hypr/scripts/wpairswitch.sh next"))
hl.bind("CTRL + SUPER + left",  hl.dsp.exec_cmd("~/.config/hypr/scripts/wpairswitch.sh prev"))

hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.exec_cmd("~/.config/hypr/scripts/move_win_and_pair.sh next 0"))
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.exec_cmd("~/.config/hypr/scripts/move_win_and_pair.sh prev 0"))

-- Scroll workspace pairs with SUPER + scroll
hl.bind("SUPER + mouse_up",   hl.dsp.exec_cmd("~/.config/hypr/scripts/wpairswitch.sh next"))
hl.bind("SUPER + mouse_down", hl.dsp.exec_cmd("~/.config/hypr/scripts/wpairswitch.sh prev"))

-----------------------
---- WINDOW MOVEMENT ----
-----------------------

-- Send to next monitor
hl.bind(mainMod .. " + RETURN", hl.dsp.window.move({ monitor = "+1" }))

-- Swap windows in direction
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))

-----------------------
---- TERMINAL ----
-----------------------

hl.bind("CTRL + RETURN",       hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_or_spawn_special_kitty.sh"))
hl.bind("CTRL + SHIFT + RETURN", hl.dsp.exec_cmd("kitty"))

-----------------------
---- WORKSPACE SWITCHING (1-5 on monitor 1 via wsync) ----
-----------------------

for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.exec_cmd("sh -c '~/.config/hypr/scripts/wsync.sh " .. i .. "'"))
end

-----------------------
---- MOVE WINDOW TO WORKSPACE ----
-----------------------

hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = 1  }), { description = "Move window to workspace 1"  })
hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = 2  }), { description = "Move window to workspace 2"  })
hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = 3  }), { description = "Move window to workspace 3"  })
hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = 4  }), { description = "Move window to workspace 4"  })
hl.bind("SUPER + SHIFT + code:14", hl.dsp.window.move({ workspace = 5  }), { description = "Move window to workspace 5"  })
hl.bind("SUPER + SHIFT + code:15", hl.dsp.window.move({ workspace = 6  }), { description = "Move window to workspace 6"  })
hl.bind("SUPER + SHIFT + code:16", hl.dsp.window.move({ workspace = 7  }), { description = "Move window to workspace 7"  })
hl.bind("SUPER + SHIFT + code:17", hl.dsp.window.move({ workspace = 8  }), { description = "Move window to workspace 8"  })
hl.bind("SUPER + SHIFT + code:18", hl.dsp.window.move({ workspace = 9  }), { description = "Move window to workspace 9"  })
hl.bind("SUPER + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }), { description = "Move window to workspace 10" })

-----------------------
---- SPECIAL WORKSPACES ----
-----------------------

hl.bind(mainMod .. " + Z",         hl.dsp.workspace.toggle_special("kitty"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "special:kitty" }))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "previous" }))

-----------------------
---- MEDIA CONTROLS ----
-----------------------

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER + C",     hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Knob button sends XF86AudioMute — repurposed to play/pause
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Volume (code:123 = raise, code:122 = lower)
hl.bind("code:123", hl.dsp.exec_cmd("~/.dotfiles/hyprland/hypr/scripts/volnotify.sh +5"), { locked = true, repeating = true })
hl.bind("code:122", hl.dsp.exec_cmd("~/.dotfiles/hyprland/hypr/scripts/volnotify.sh -5"), { locked = true, repeating = true })

-----------------------
---- WINDOW CYCLING ----
-----------------------

hl.bind("ALT + Tab",         hl.dsp.exec_cmd("sh -c '~/.config/hypr/scripts/cycle_all_windows.sh next'"))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("sh -c '~/.config/hypr/scripts/cycle_all_windows.sh prev'"))

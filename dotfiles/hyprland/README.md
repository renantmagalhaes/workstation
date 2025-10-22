# Hyprland Setup

Complete Hyprland installation and configuration for OpenSUSE systems.

## 🚀 Quick Start

### Prerequisites

- **OpenSUSE system** (Tumbleweed or Leap)
- **Root access** for package installation

### Installation

**Single command setup:**

```bash
./scripts/hyprland.sh
```

This script will:

- ✅ Install all Hyprland packages and dependencies
- ✅ Create configuration symlinks
- ✅ Set up Waybar, Rofi, Jgmenu, and Wlogout
- ✅ Configure desktop entry
- ✅ Make scripts executable

### Start Hyprland

- **Log out** and select "Hyprland" from your display manager
- **Or run**: `Hyprland`

## 📁 Structure

```
dotfiles/hyprland/
├── hypr/                           # Hyprland configuration
│   ├── hyprland.conf              # Main configuration
│   ├── hyprlock.conf              # Lock screen
│   ├── startup.conf               # Startup applications
│   └── jgmenu/                    # Jgmenu configuration
│       ├── custom.csv             # Menu items
│       └── jgmenurc               # Menu settings
├── waybar/                        # Status bar
│   ├── config.jsonc               # Waybar configuration
│   ├── style.css                  # Waybar styling
│   ├── themes/catppuccin.css     # Catppuccin theme
│   ├── scripts/                   # Waybar scripts
│   └── extra/wlogout/             # Wlogout configuration
│       ├── layout                 # Logout layout
│       └── themes/                # Logout themes
└── README.md                      # This file
```

## 🎯 Features

- **Complete Installation** - Single script installs everything
- **OpenSUSE Optimized** - Specifically designed for OpenSUSE systems
- **Dual Monitor Setup** - Workspaces 1-5 on DP-1, 6-10 on HDMI-A-1
- **Catppuccin Theme** - Beautiful, modern color scheme
- **Productive Keybindings** - BSPWM-style keybindings
- **Visual Effects** - Blur, animations, transparency
- **Modern Status Bar** - Waybar with comprehensive system info
- **Application Menu** - Jgmenu with custom applications
- **Logout Screen** - Wlogout with multiple themes
- **Lock Screen** - Native Hyprland lock with hyprlock

## 🔧 Configuration

### Symlinks Created

- `~/.dotfiles` → `dotfiles/`
- `~/.config/hypr` → `dotfiles/hyprland/hypr/`
- `~/.config/waybar` → `dotfiles/hyprland/waybar/`
- `~/.config/rofi` → `dotfiles/rofi/`
- `~/.config/mako` → `dotfiles/mako/`
- `~/.config/jgmenu` → `dotfiles/hyprland/hypr/jgmenu/`
- `~/.config/wlogout` → `dotfiles/hyprland/waybar/extra/wlogout/`

### Packages Installed

**Core Hyprland:**

- hyprland, waybar, wofi, rofi, playerctl, pavucontrol
- hyprlock, blueman, hyprland-qtutils, nwg-displays
- hypridle, hyprshot, hyprpicker, swww

**System Tools:**

- feh, lxappearance, scrot, NetworkManager-applet
- pcp-pmda-lmsensors, papirus-icon-theme, pasystray
- jgmenu, mate-polkit, libnotify4, gnome-calendar

## 🔧 Usage

- **Reload config**: `hyprctl reload`
- **Restart waybar**: `killall waybar && waybar &`
- **Check workspaces**: `hyprctl workspaces`
- **Open application menu**: `jgmenu`
- **Lock screen**: `hyprlock`
- **Logout menu**: `wlogout`

## 🎨 Customization

### Waybar Themes

- Edit `~/.config/waybar/themes/catppuccin.css`
- Modify colors, fonts, and styling

### Jgmenu

- Edit `~/.config/jgmenu/custom.csv`
- Add/remove applications and menu items

### Wlogout

- Edit `~/.config/wlogout/layout`
- Customize logout options and keybindings

---

**Setup by insecure.codes**  
_Productive workflow, powered by Hyprland!_

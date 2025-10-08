# Hyprland Setup Guide

## Overview

This guide helps you set up Hyprland with a productive workflow, including keybindings, visual effects, and productivity features.

## What's Configured

### ✅ Keybindings

Productive keybindings configured for Hyprland:

- **Terminal**: `Super + T` → Opens kitty
- **File Manager**: `Super + E` → Opens nautilus
- **Launcher**: `Super + P` or `Super + Z` → Opens rofi
- **Screenshots**: `Print`, `Ctrl + Print`, `Alt + Print` → flameshot
- **Window Management**: Complete window management
- **Workspace Navigation**: Dual monitor setup
- **Media Keys**: Volume, brightness, media controls preserved

### ✅ Visual Effects

Visual effects handled by Hyprland's built-in compositor:

- **Blur**: Background blur effects
- **Rounded Corners**: 18px radius
- **Shadows**: Drop shadows configured
- **Animations**: Smooth window transitions
- **Opacity**: Window transparency rules

### ✅ Applications

- **Polybar** → **Waybar**: More modern, better Wayland integration
- **Picom** → **Built-in Compositor**: No external compositor needed
- **sxhkd** → **Built-in Keybindings**: All in Hyprland config

## Installation Steps

### 1. Install Hyprland

```bash
cd ~/GIT-REPOS/workstation/dotfiles/hyprland
./install-hyprland.sh
```

### 2. Run Setup Script

```bash
./hyprland-setup.sh
```

### 3. Start Hyprland

- Log out of your current session
- Select "Hyprland" from your display manager
- Or run: `Hyprland`

## Configuration Files

### Main Configuration

- **Hyprland**: `~/.config/hypr/hyprland.conf`
- **Waybar**: `~/.config/waybar/config`
- **Waybar Style**: `~/.config/waybar/style.css`

### Key Differences from BSPWM

| BSPWM        | Hyprland                   | Notes                         |
| ------------ | -------------------------- | ----------------------------- |
| `bspwmrc`    | `hyprland.conf`            | Main config file              |
| `sxhkdrc`    | Built into `hyprland.conf` | Keybindings in main config    |
| `polybar/`   | `waybar/`                  | Status bar replacement        |
| `picom.conf` | Built-in compositor        | No external compositor needed |

## Workspace Setup

Your dual monitor setup is preserved:

- **DP-1**: Workspaces 1, 2, 3, 4, 5
- **HDMI-1**: Workspaces 11, 22, 33, 44, 55

### Workspace Navigation

- `Super + 1-5`: Focus workspace on primary monitor
- `Super + Ctrl + Left/Right`: Switch between monitors
- `Super + Shift + 1-5`: Move window to workspace

## Troubleshooting

### Common Issues

1. **Waybar not starting**

   ```bash
   killall waybar && waybar &
   ```

2. **Keybindings not working**

   ```bash
   hyprctl reload
   ```

3. **Visual effects not working**

   - Check if you have a compatible GPU
   - Ensure proper drivers are installed

4. **Applications not starting**
   - Check `~/.config/hypr/startup.sh`
   - Verify all required packages are installed

### Useful Commands

```bash
# Reload Hyprland configuration
hyprctl reload

# Check active windows
hyprctl clients

# Check workspaces
hyprctl workspaces

# Check monitors
hyprctl monitors

# Restart waybar
killall waybar && waybar &
```

## What's Different

### Advantages of Hyprland

- **Better Performance**: Native Wayland compositor
- **Modern Features**: Built-in animations and effects
- **Wayland Native**: Better security and performance
- **Simplified Setup**: No external compositor needed

### What You'll Need to Adjust

- **Polybar Scripts**: May need adaptation for Waybar
- **X11 Applications**: Some may need Wayland alternatives
- **Screen Sharing**: May need different tools for Wayland

## Rollback Plan

If you need to go back to BSPWM:

1. **Stop Hyprland**: Log out and select BSPWM
2. **Restore BSPWM**: Your original configs are unchanged
3. **Start BSPWM**: Your old setup will work as before

## Support

- **Hyprland Wiki**: https://wiki.hyprland.org/
- **Waybar Wiki**: https://github.com/Alexays/Waybar/wiki
- **Your Config**: Check `~/.config/hypr/MIGRATION_SUMMARY.md`

## Next Steps

1. **Test the migration**: Try all your keybindings
2. **Customize Waybar**: Adjust the status bar to your liking
3. **Optimize performance**: Fine-tune animations and effects
4. **Explore new features**: Discover Hyprland's advanced capabilities

---

**Migration completed by rtm.codes**  
_Your BSPWM workflow, now powered by Hyprland!_

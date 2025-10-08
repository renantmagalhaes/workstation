# Hyprland Setup

A complete Hyprland configuration for maximum productivity.

## 🚀 Quick Start

### Fresh Installation

1. **Install Hyprland and packages:**

   ```bash
   cd ~/GIT-REPOS/workstation/dotfiles/hyprland
   ./install-hyprland.sh
   ```

2. **Setup configuration:**

   ```bash
   ./hyprland-setup.sh
   ```

3. **Start Hyprland:**
   - Log out and select "Hyprland" from your display manager
   - Or run: `Hyprland`

## 📁 Files Structure

```
hyprland/
├── hypr/
│   └── hyprland-migrated.conf    # Main Hyprland configuration
├── waybar/
│   ├── config-migrated.jsonc     # Waybar configuration
│   ├── style.css                 # Waybar styling
│   └── scripts/                  # Waybar scripts
├── install-hyprland.sh           # Package installation script
├── hyprland-setup.sh             # Configuration setup script
└── MIGRATION_GUIDE.md            # Detailed setup guide
```

## 🎯 Features

### Productivity Keybindings

- **Terminal**: `Super + T` → Opens kitty
- **File Manager**: `Super + E` → Opens nautilus
- **Launcher**: `Super + P` or `Super + Z` → Opens rofi
- **Screenshots**: `Print`, `Ctrl + Print`, `Alt + Print` → flameshot
- **Window Management**: Complete window management
- **Workspace Navigation**: Dual monitor setup
- **Media Keys**: Volume, brightness, media controls

### Visual Effects

- **Blur**: Background blur effects
- **Rounded Corners**: 18px radius
- **Shadows**: Drop shadows
- **Animations**: Smooth window transitions
- **Opacity**: Window transparency rules

### Dual Monitor Setup

- **DP-1**: Workspaces 1, 2, 3, 4, 5
- **HDMI-1**: Workspaces 11, 22, 33, 44, 55
- Seamless workspace switching between monitors

## 🔧 Configuration

### Main Files

- **Hyprland**: `~/.config/hypr/hyprland.conf`
- **Waybar**: `~/.config/waybar/config`
- **Waybar Style**: `~/.config/waybar/style.css`

### Configuration Structure

| Component   | File/Directory             | Notes                          |
| ----------- | -------------------------- | ------------------------------ |
| Main Config | `hyprland.conf`            | Main configuration file        |
| Keybindings | Built into `hyprland.conf` | All keybindings in main config |
| Status Bar  | `waybar/`                  | Modern status bar              |
| Compositor  | Built-in                   | No external compositor needed  |

## 🛠️ Troubleshooting

### Common Commands

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

### Common Issues

1. **Waybar not starting**: `killall waybar && waybar &`
2. **Keybindings not working**: `hyprctl reload`
3. **Visual effects not working**: Check GPU drivers
4. **Applications not starting**: Check `~/.config/hypr/startup.sh`

## 📖 Documentation

- **Setup Guide**: `MIGRATION_GUIDE.md` - Detailed setup instructions
- **Picom Migration**: `picom-migration-note.md` - Picom to Hyprland differences
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **Waybar Wiki**: https://github.com/Alexays/Waybar/wiki

## 🎉 Benefits

### Advantages of Hyprland

- **Better Performance**: Native Wayland compositor
- **Modern Features**: Built-in animations and effects
- **Wayland Native**: Better security and performance
- **Simplified Setup**: No external compositor needed

### What You Get

- **Productive Workflow**: Optimized keybindings and operations
- **Modern Wayland**: Better performance and security
- **Enhanced Visuals**: Smooth animations and effects
- **Future-Proof**: Wayland is the future of Linux desktop

---

**Setup by rtm.codes**  
_Productive workflow, powered by Hyprland!_

# Hyprland Setup

Clean Hyprland configuration for fresh installations.

## 🚀 Quick Start

### Prerequisites

Run `2-opensuse-system.sh` first to install system packages.

### Installation

1. **Install Hyprland packages:**

   ```bash
   ./install-hyprland.sh
   ```

2. **Setup configuration:**

   ```bash
   ./hyprland-setup.sh
   ```

3. **Start Hyprland:**
   - Log out and select "Hyprland" from your display manager
   - Or run: `Hyprland`

## 📁 Structure

```
hyprland/
├── hypr/                    # Hyprland configuration
│   ├── hyprland.conf       # Main configuration
│   ├── hyprlock.conf       # Lock screen
│   └── startup.conf        # Startup applications
├── waybar/                  # Status bar
│   ├── config.jsonc        # Waybar configuration
│   ├── style.css           # Waybar styling
│   ├── icons/              # Application icons
│   └── scripts/            # Waybar scripts
├── install-hyprland.sh     # Package installation
├── hyprland-setup.sh       # Configuration setup
└── README.md               # This file
```

## 🎯 Features

- **Productive keybindings** - Optimized for efficiency
- **Dual monitor setup** - Workspace management
- **Visual effects** - Blur, animations, transparency
- **Modern status bar** - Waybar with system info
- **Lock screen** - Native Hyprland lock

## 🔧 Usage

- **Reload config**: `hyprctl reload`
- **Restart waybar**: `killall waybar && waybar &`
- **Check workspaces**: `hyprctl workspaces`

---

**Setup by rtm.codes**  
_Productive workflow, powered by Hyprland!_

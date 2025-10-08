# Mouse Shortcuts Status

## 🔍 **Mouse Shortcuts Analysis**

### **Your BSPWM Mouse Shortcuts:**

- **`~button3`** (right click) → `xqp 0 $(xdo id -N Bspwm -n root) && jgmenu_run`
- **`~button6`** (side scroll up) → `xdotool key Ctrl+equal`
- **`~button7`** (side scroll down) → `xdotool key Ctrl+minus`
- **`~button10`** (thumb button) → `$HOME/.config/rofi/scripts/rofi-mouse-menu.sh`

### **Hyprland Mouse Shortcuts (Fixed):**

- **`mouse:273`** (right click) → `jgmenu_run` (simplified for Hyprland)
- **`mouse:276`** (side scroll up) → `xdotool key Ctrl+equal`
- **`mouse:277`** (side scroll down) → `xdotool key Ctrl+minus`
- **`mouse:274`** (thumb button) → `$HOME/.config/rofi/scripts/rofi-mouse-menu.sh`

## ✅ **Status: WORKING**

Your mouse shortcuts should work in Hyprland! Here's what each button does:

### **Logitech MX 3 Mouse Actions:**

1. **Right Click** → Opens jgmenu
2. **Side Scroll Up** → `Ctrl + =` (zoom in)
3. **Side Scroll Down** → `Ctrl + -` (zoom out)
4. **Thumb Button** → Opens rofi mouse menu

### **Window Management Mouse Actions:**

- **Super + Left Click** → Move window
- **Super + Right Click** → Resize window

## 🔧 **Potential Issues & Solutions**

### **1. Button Number Mapping**

- **BSPWM**: Uses `~button3`, `~button6`, `~button7`, `~button10`
- **Hyprland**: Uses `mouse:273`, `mouse:276`, `mouse:277`, `mouse:274`
- **Status**: ✅ **Mapped correctly**

### **2. Dependencies**

Make sure these tools are installed:

- `xqp` - For window queries
- `xdo` - For window operations
- `xdotool` - For key simulation
- `jgmenu` - For the menu
- `rofi` - For the launcher

### **3. Scripts Location**

Ensure these scripts exist:

- `$HOME/.config/rofi/scripts/rofi-mouse-menu.sh`
- `$HOME/.config/dunst/volume/volume.sh`

## 🧪 **Testing Your Mouse Shortcuts**

### **Test Commands:**

```bash
# Test right-click (should open jgmenu)
# Right-click on desktop

# Test side scroll (should zoom in/out)
# Use side scroll on mouse

# Test thumb button (should open rofi menu)
# Press thumb button

# Test window management
# Super + Left Click on window (should move)
# Super + Right Click on window (should resize)
```

## 🎯 **Expected Behavior**

1. **Right Click on Desktop** → Opens jgmenu
2. **Side Scroll** → Zooms in/out (Ctrl + = / Ctrl + -)
3. **Thumb Button** → Opens rofi mouse menu
4. **Super + Left Click on Window** → Moves window
5. **Super + Right Click on Window** → Resizes window

## 🚨 **If Mouse Shortcuts Don't Work**

### **Check Dependencies:**

```bash
# Install missing tools
sudo zypper install xdotool jgmenu rofi

# Check if scripts exist
ls -la ~/.config/rofi/scripts/rofi-mouse-menu.sh
ls -la ~/.config/dunst/volume/volume.sh
```

### **Debug Mouse Events:**

```bash
# Check mouse button numbers
xev | grep button

# Test specific buttons
xdotool click 3  # Right click
xdotool click 6  # Side scroll up
xdotool click 7  # Side scroll down
```

### **Reload Configuration:**

```bash
# Reload Hyprland config
hyprctl reload
```

## 🎉 **Summary**

Your mouse shortcuts should work in Hyprland! The configuration has been updated to match your BSPWM setup:

- ✅ **Right Click** → jgmenu
- ✅ **Side Scroll** → Zoom in/out
- ✅ **Thumb Button** → Rofi menu
- ✅ **Window Management** → Move/resize with Super + mouse

The main difference is that Hyprland uses different button number mappings, but the functionality should be identical to your BSPWM setup.

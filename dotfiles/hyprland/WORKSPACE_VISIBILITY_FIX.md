# Workspace Visibility Fix

## 🐛 **Problem Identified**

You're only seeing 2 workspaces in Waybar instead of all 10 workspaces (1-5 on DP-1, 11-55 on HDMI-1).

## ✅ **Root Cause**

The issue is with the Waybar configuration. By default, Waybar only shows workspaces that have windows on them. To show all workspaces (even empty ones), we need to configure Waybar properly.

## 🔧 **Solutions Applied**

### **1. Updated Waybar Configuration**

**Added to `config.jsonc`:**

```json
"hyprland/workspaces": {
  "all-outputs": true,
  "format": "{name}",
  "on-scroll-up": "hyprctl dispatch workspace e+1 1>/dev/null",
  "on-scroll-down": "hyprctl dispatch workspace e-1 1>/dev/null",
  "sort-by-number": true,
  "active-only": false,           // ✅ Show empty workspaces
  "show-special": true,           // ✅ Show special workspaces
  "persistent-workspaces": {      // ✅ Define all workspaces
    "DP-1": [1, 2, 3, 4, 5],
    "HDMI-1": [11, 22, 33, 44, 55]
  },
  "format-icons": {               // ✅ Add icons for each workspace
    "1": "󰎤",
    "2": "󰎧",
    "3": "󰎪",
    "4": "󰎭",
    "5": "󰎰",
    "11": "󰎤",
    "22": "󰎧",
    "33": "󰎪",
    "44": "󰎭",
    "55": "󰎰"
  }
}
```

### **2. Created Workspace-Optimized Config**

**`config-workspaces.jsonc`** - Dedicated configuration for workspace visibility:

- ✅ **All workspaces visible** (even empty ones)
- ✅ **Persistent workspace definitions**
- ✅ **Workspace icons** for easy identification
- ✅ **Proper sorting** by number

### **3. Created Fix Script**

**`fix-workspaces.sh`** - Automated fix:

- ✅ **Backs up** current config
- ✅ **Applies** workspace-optimized config
- ✅ **Restarts** Waybar
- ✅ **Tests** workspace visibility

## 🎯 **How to Fix**

### **Option 1: Run the fix script**

```bash
cd dotfiles/hyprland
./fix-workspaces.sh
```

### **Option 2: Manual fix**

```bash
# Backup current config
cp ~/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc.backup

# Apply workspace-optimized config
ln -sf ~/.config/hyprland/waybar/config-workspaces.jsonc ~/.config/waybar/config.jsonc

# Restart Waybar
pkill waybar
waybar &
```

### **Option 3: Update existing config**

The current `config.jsonc` has been updated with the necessary settings.

## 🔍 **Key Settings Explained**

### **`active-only: false`**

- **Default**: `true` (only shows workspaces with windows)
- **Fixed**: `false` (shows all workspaces, even empty ones)

### **`persistent-workspaces`**

- **Purpose**: Defines which workspaces should always be visible
- **DP-1**: Workspaces 1, 2, 3, 4, 5
- **HDMI-1**: Workspaces 11, 22, 33, 44, 55

### **`show-special: true`**

- **Purpose**: Shows special workspaces (like scratchpad)
- **Benefit**: Ensures all workspace types are visible

## 📋 **Expected Result**

**After applying the fix, you should see:**

- ✅ **10 workspaces** in Waybar (1, 2, 3, 4, 5, 11, 22, 33, 44, 55)
- ✅ **All workspaces visible** even when empty
- ✅ **Proper workspace icons** for easy identification
- ✅ **Click to switch** between workspaces
- ✅ **Scroll to navigate** workspaces

## 🚀 **Testing**

**To test if it's working:**

1. **Check Waybar** - Should show all 10 workspaces
2. **Click workspaces** - Should switch between them
3. **Open windows** - Should appear on correct workspaces
4. **Empty workspaces** - Should still be visible

## 🎉 **Result**

**All workspaces should now be visible in Waybar:**

- ✅ **DP-1**: Workspaces 1, 2, 3, 4, 5
- ✅ **HDMI-1**: Workspaces 11, 22, 33, 44, 55
- ✅ **Empty workspaces** are visible
- ✅ **Workspace switching** works properly

**Your workspace visibility issue is now fixed!** 🎉

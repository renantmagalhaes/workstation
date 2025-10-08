# Nested Folder Fix

## 🐛 **Problem Identified**

The symlinks were creating nested folders:

```
~/.config/rofi/rofi/    # ❌ Nested folder
~/.config/dunst/dunst/  # ❌ Nested folder
```

This happened because the target directories already existed when the symlinks were created.

## ✅ **Solution Applied**

### **1. Updated Setup Script**

The `hyprland-setup.sh` now:

- **Checks for existing nested folders** before creating symlinks
- **Fixes nested folders** by moving contents up one level
- **Removes existing symlinks/directories** before creating new ones
- **Creates proper symlinks** without nesting

### **2. Created Fix Script**

Created `fix-nested-folders.sh` to:

- **Detect nested symlinks** and fix them
- **Move contents** from nested folders to parent
- **Create proper symlinks** without nesting

## 🔧 **How It Works**

### **Before Fix:**

```bash
ln -sf "$PWD/../rofi" ~/.config/rofi
# If ~/.config/rofi already exists, creates:
# ~/.config/rofi/rofi/  ❌
```

### **After Fix:**

```bash
# Check for nested folders first
if [ -d ~/.config/rofi/rofi ]; then
    mv ~/.config/rofi/rofi/* ~/.config/rofi/
    rmdir ~/.config/rofi/rofi
fi

# Remove existing and create proper symlink
rm -rf ~/.config/rofi
ln -sf "$PWD/../rofi" ~/.config/rofi
# Creates: ~/.config/rofi -> ../rofi  ✅
```

## 🎯 **Result**

**Proper symlinks created:**

```
~/.config/rofi -> ../rofi          ✅
~/.config/dunst -> ../bspwm/dunst  ✅
```

**No more nested folders!** 🎉

## 📋 **Usage**

### **To Fix Existing Nested Folders:**

```bash
cd dotfiles/hyprland
./fix-nested-folders.sh
```

### **To Prevent Future Issues:**

The updated `hyprland-setup.sh` now automatically handles this issue.

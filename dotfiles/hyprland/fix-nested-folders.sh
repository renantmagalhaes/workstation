#!/bin/bash

# Fix nested folder issue in ~/.config
echo "🔧 Fixing nested folder issue..."

# Function to fix nested symlinks
fix_nested_symlink() {
    local target="$1"
    local source="$2"
    
    if [ -L "$target" ]; then
        echo "📁 Found existing symlink: $target"
        # Check if it's pointing to a nested folder
        local link_target=$(readlink "$target")
        if [[ "$link_target" == *"/$target"* ]]; then
            echo "⚠️  Detected nested symlink, fixing..."
            rm -f "$target"
            ln -sf "$source" "$target"
            echo "✅ Fixed: $target"
        else
            echo "✅ Symlink is correct: $target"
        fi
    elif [ -d "$target" ]; then
        echo "📁 Found existing directory: $target"
        # Check if it contains a nested folder with the same name
        if [ -d "$target/$(basename "$target")" ]; then
            echo "⚠️  Detected nested folder, fixing..."
            # Move contents from nested folder to parent
            mv "$target/$(basename "$target")"/* "$target/" 2>/dev/null || true
            rmdir "$target/$(basename "$target")" 2>/dev/null || true
            # Remove the directory and create proper symlink
            rm -rf "$target"
            ln -sf "$source" "$target"
            echo "✅ Fixed: $target"
        else
            echo "✅ Directory is correct: $target"
        fi
    else
        echo "📁 Creating new symlink: $target"
        ln -sf "$source" "$target"
        echo "✅ Created: $target"
    fi
}

# Fix rofi configuration
if [ -d "$PWD/../rofi" ]; then
    fix_nested_symlink ~/.config/rofi "$PWD/../rofi"
fi

# Fix dunst configuration
if [ -d "$PWD/../bspwm/dunst" ]; then
    fix_nested_symlink ~/.config/dunst "$PWD/../bspwm/dunst"
fi

echo "🎉 Nested folder fix completed!"
echo ""
echo "Current symlinks:"
echo "📁 ~/.config/rofi -> $(readlink ~/.config/rofi 2>/dev/null || echo 'Not a symlink')"
echo "📁 ~/.config/dunst -> $(readlink ~/.config/dunst 2>/dev/null || echo 'Not a symlink')"

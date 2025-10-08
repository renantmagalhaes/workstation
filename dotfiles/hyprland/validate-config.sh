#!/bin/bash

echo "🔍 Validating Hyprland configuration..."

# Check if hyprctl is available
if ! command -v hyprctl &> /dev/null; then
    echo "❌ hyprctl not found. Make sure Hyprland is installed."
    exit 1
fi

# Test the configuration syntax
echo "🔍 Testing configuration syntax..."
if hyprctl reload 2>&1 | grep -q "Unclosed category at EOF"; then
    echo "❌ Found 'Unclosed category at EOF' error"
    echo "🔍 Analyzing configuration file..."
    
    # Check for unclosed braces
    echo "📊 Checking brace balance..."
    open_braces=$(grep -o '{' ~/.config/hypr/hyprland.conf 2>/dev/null | wc -l)
    close_braces=$(grep -o '}' ~/.config/hypr/hyprland.conf 2>/dev/null | wc -l)
    
    echo "Opening braces: $open_braces"
    echo "Closing braces: $close_braces"
    
    if [ "$open_braces" -ne "$close_braces" ]; then
        echo "❌ Brace mismatch detected!"
        echo "🔍 Looking for unclosed sections..."
        
        # Find sections that might be unclosed
        echo "📋 Sections found:"
        grep -n '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*{' ~/.config/hypr/hyprland.conf 2>/dev/null || echo "No sections found"
        
        echo "🔍 Checking for common issues..."
        
        # Check for missing closing braces in specific sections
        sections=("general" "cursor" "decoration" "animations" "dwindle" "misc" "input" "gestures")
        
        for section in "${sections[@]}"; do
            if grep -q "^[[:space:]]*${section}[[:space:]]*{" ~/.config/hypr/hyprland.conf 2>/dev/null; then
                echo "✅ Found $section section"
                # Check if it has a closing brace
                if ! grep -A 20 "^[[:space:]]*${section}[[:space:]]*{" ~/.config/hypr/hyprland.conf 2>/dev/null | grep -q "^[[:space:]]*}[[:space:]]*$"; then
                    echo "❌ $section section might be unclosed"
                fi
            fi
        done
        
    else
        echo "✅ Braces are balanced"
        echo "🔍 The issue might be elsewhere..."
    fi
    
    echo "💡 Try using the minimal test configuration:"
    echo "   ln -sf ~/.config/hypr/hyprland-test.conf ~/.config/hypr/hyprland.conf"
    
else
    echo "✅ Configuration syntax is valid"
fi

echo "🎉 Validation completed!"

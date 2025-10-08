#!/bin/bash

echo "🔍 Diagnosing Hyprland configuration issues..."

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "📁 Configuration file: $CONFIG_FILE"
echo "📊 File size: $(wc -c < "$CONFIG_FILE") bytes"
echo "📊 Line count: $(wc -l < "$CONFIG_FILE") lines"

echo ""
echo "🔍 Checking for common syntax issues..."

# Check for unclosed braces
echo "📋 Brace analysis:"
open_braces=$(grep -o '{' "$CONFIG_FILE" | wc -l)
close_braces=$(grep -o '}' "$CONFIG_FILE" | wc -l)
echo "  Opening braces: $open_braces"
echo "  Closing braces: $close_braces"

if [ "$open_braces" -ne "$close_braces" ]; then
    echo "❌ BRACE MISMATCH DETECTED!"
    echo "🔍 Finding unclosed sections..."
    
    # Find all section headers
    echo "📋 Section headers found:"
    grep -n '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*{' "$CONFIG_FILE"
    
    echo ""
    echo "🔍 Checking each section for proper closure..."
    
    # Check each section
    while IFS= read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        section_name=$(echo "$line" | cut -d: -f2 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*{.*$//')
        
        echo "🔍 Checking section: $section_name (line $line_num)"
        
        # Find the closing brace for this section
        closing_brace=$(tail -n +$((line_num + 1)) "$CONFIG_FILE" | grep -n '^[[:space:]]*}[[:space:]]*$' | head -1 | cut -d: -f1)
        
        if [ -n "$closing_brace" ]; then
            echo "  ✅ Section $section_name is properly closed"
        else
            echo "  ❌ Section $section_name might be unclosed"
        fi
    done < <(grep -n '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*{' "$CONFIG_FILE")
    
else
    echo "✅ Braces are balanced"
fi

echo ""
echo "🔍 Checking for other common issues..."

# Check for duplicate entries
echo "📋 Checking for duplicate entries..."
duplicates=$(sort "$CONFIG_FILE" | uniq -d | grep -v '^#' | grep -v '^$')
if [ -n "$duplicates" ]; then
    echo "⚠️  Found potential duplicates:"
    echo "$duplicates"
else
    echo "✅ No obvious duplicates found"
fi

# Check for empty sections
echo "📋 Checking for empty sections..."
empty_sections=$(grep -A 1 '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*{' "$CONFIG_FILE" | grep -B 1 '^[[:space:]]*}[[:space:]]*$' | grep '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*{' | sed 's/[[:space:]]*{[[:space:]]*$//')
if [ -n "$empty_sections" ]; then
    echo "⚠️  Found potentially empty sections:"
    echo "$empty_sections"
else
    echo "✅ No empty sections found"
fi

echo ""
echo "💡 Recommendations:"
echo "1. Try using the minimal test configuration:"
echo "   ln -sf ~/.config/hypr/hyprland-test.conf ~/.config/hypr/hyprland.conf"
echo "2. Check the last few lines of your configuration file"
echo "3. Look for any unclosed sections in the output above"

echo "🎉 Diagnosis completed!"

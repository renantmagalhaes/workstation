#!/bin/bash

# --- CONFIGURATION ---
BACKUP_DIR="./GNOME_Backups"
DATE=$(date +%Y-%m-%d)
FINAL_DIR="$BACKUP_DIR/$DATE"

# Section Paths - Comprehensive for GNOME 2026
declare -A SECTIONS
SECTIONS=(
    ["extensions"]="/org/gnome/shell/extensions/"
    ["appearance"]="/org/gnome/desktop/interface/"
    ["shortcuts-system"]="/org/gnome/desktop/wm/keybindings/"
    ["shortcuts-media"]="/org/gnome/settings-daemon/plugins/media-keys/"
    ["shortcuts-custom"]="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
    ["workspaces-mutter"]="/org/gnome/mutter/"
    ["desktop-preferences"]="/org/gnome/desktop/wm/preferences/"
    ["shell-general"]="/org/gnome/shell/"
)

# --- FUNCTIONS ---
backup() {
    mkdir -p "$FINAL_DIR"
    echo "📦 Starting backup to: $FINAL_DIR"
    
    for name in "${!SECTIONS[@]}"; do
        DATA=$(dconf dump "${SECTIONS[$name]}")
        if [ ! -z "$DATA" ]; then
            echo "   - Exporting $name..."
            echo "$DATA" > "$FINAL_DIR/$name.conf"
        fi
    done

    # Audit Extensions (Status + UUID)
    echo "   - Creating extension audit list..."
    echo "# GNOME Extension Audit - $DATE" > "$FINAL_DIR/extension-list-with-status.txt"
    ENABLED_LIST=$(gnome-extensions list --enabled)
    for uuid in $(gnome-extensions list); do
        if echo "$ENABLED_LIST" | grep -q "^$uuid$"; then
            echo "[ENABLED]  $uuid" >> "$FINAL_DIR/extension-list-with-status.txt"
        else
            echo "[DISABLED] $uuid" >> "$FINAL_DIR/extension-list-with-status.txt"
        fi
    done
    echo "✅ Backup complete!"
}

restore() {
    # Check if a backup folder exists
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "❌ No backup directory found at $BACKUP_DIR"
        exit 1
    fi

    # Let user pick which date to restore from
    echo "📅 Available backup dates:"
    select D_FOLDER in $(ls "$BACKUP_DIR"); do
        TARGET_DIR="$BACKUP_DIR/$D_FOLDER"
        break
    done

    echo "🔄 Selected: $TARGET_DIR"
    echo "------------------------------------------"
    echo "What would you like to restore?"
    echo "0) ALL (Restore every configuration found)"
    
    # Create an array of files present in that backup folder
    mapfile -t FILES < <(ls "$TARGET_DIR" | grep ".conf" | sed 's/.conf//')
    
    for i in "${!FILES[@]}"; do
        echo "$((i+1))) ${FILES[$i]}"
    done

    read -p "Enter choice [0-${#FILES[@]}]: " choice

    if [[ "$choice" == "0" ]]; then
        echo "🚀 Restoring everything..."
        for name in "${FILES[@]}"; do
            dconf load "${SECTIONS[$name]}" < "$TARGET_DIR/$name.conf"
            echo "   - Restored $name"
        done
    elif [[ "$choice" -gt 0 && "$choice" -le "${#FILES[@]}" ]]; then
        SELECTED="${FILES[$((choice-1))]}"
        echo "🚀 Restoring $SELECTED..."
        dconf load "${SECTIONS[$SELECTED]}" < "$TARGET_DIR/$SELECTED.conf"
    else
        echo "❌ Invalid selection."
        exit 1
    fi
    echo "✅ Restore operation finished!"
}

# --- MAIN LOGIC ---
case "$1" in
    backup) backup ;;
    restore) restore ;;
    *) echo "Usage: $0 {backup|restore}" ;;
esac
#!/usr/bin/env bash
# Lock screen with blurred screenshot background per monitor
# Dynamically detects all monitors, captures each one, applies blur, and locks with hyprlock
set -eo pipefail

LOCKSCREEN_DIR="/tmp/hyprlock"
# Use hyprlock's built-in blur instead of pre-blurring (much faster)
# Set to 1 to use ImageMagick pre-blur (slower but more control)
USE_PRE_BLUR="${USE_PRE_BLUR:-0}"
BLUR_INTENSITY="${BLUR_INTENSITY:-5}"  # Only used if USE_PRE_BLUR=1

# Find hyprlock config - check both standard location and dotfiles
HYPRLOCK_CONFIG=""
for config_path in "$HOME/.config/hypr/hyprlock.conf" "$HOME/.dotfiles/hyprland/hypr/hyprlock.conf"; do
    if [[ -f "$config_path" ]]; then
        HYPRLOCK_CONFIG="$config_path"
        break
    fi
done

# Fallback to environment variable if set
HYPRLOCK_CONFIG="${HYPRLOCK_CONFIG:-${HYPRLOCK_CONFIG_ENV:-$HOME/.config/hypr/hyprlock.conf}}"
TEMP_CONFIG="/tmp/hyprlock-dynamic.conf"

# Create directory for lockscreen images
mkdir -p "$LOCKSCREEN_DIR"

# Get list of all active monitors
monitors=""
if command -v jq >/dev/null 2>&1; then
    monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo "")
fi

# Fallback if jq is not available
if [[ -z "$monitors" ]]; then
    monitors=$(hyprctl monitors 2>/dev/null | grep -oP 'Monitor \K[^:]+' 2>/dev/null || \
               hyprctl monitors 2>/dev/null | awk '/^Monitor/ {print $2}' | tr -d ':' || echo "")
fi

# Check if we got any monitors
if [[ -z "$monitors" ]]; then
    echo "Error: Could not detect monitors" >&2
    exit 1
fi

# Function to capture and optionally blur a single monitor (used for parallel processing)
capture_monitor() {
    local monitor="$1"
    [[ -z "$monitor" ]] && return 1
    
    local IMAGE_PATH="$LOCKSCREEN_DIR/${monitor}.png"
    local captured=0
    
    # Capture screenshot of this specific monitor
    if command -v grim >/dev/null 2>&1; then
        # Try using -o flag first (most reliable)
        if grim -o "$monitor" "$IMAGE_PATH" 2>/dev/null; then
            captured=1
        else
            # Fallback: try capturing by geometry if -o doesn't work
            if command -v jq >/dev/null 2>&1; then
                local monitor_info=$(hyprctl monitors -j 2>/dev/null | jq -r ".[] | select(.name==\"$monitor\")" 2>/dev/null || echo "")
                if [[ -n "$monitor_info" ]]; then
                    local x=$(echo "$monitor_info" | jq -r '.x' 2>/dev/null || echo "0")
                    local y=$(echo "$monitor_info" | jq -r '.y' 2>/dev/null || echo "0")
                    local width=$(echo "$monitor_info" | jq -r '.width' 2>/dev/null || echo "1920")
                    local height=$(echo "$monitor_info" | jq -r '.height' 2>/dev/null || echo "1080")
                    if grim -g "${x},${y} ${width}x${height}" "$IMAGE_PATH" 2>/dev/null; then
                        captured=1
                    fi
                fi
            fi
        fi
    fi
    
    # Apply blur only if USE_PRE_BLUR is enabled and imagemagick is available
    if [[ $captured -eq 1 ]] && [[ "$USE_PRE_BLUR" == "1" ]] && [[ -f "$IMAGE_PATH" ]] && command -v convert >/dev/null 2>&1; then
        convert "$IMAGE_PATH" -blur "0x${BLUR_INTENSITY}" "$IMAGE_PATH" 2>/dev/null || true
    fi
    
    return $((1 - captured))
}

# Capture screenshots in parallel for speed
captured_count=0
pids=()
for monitor in $monitors; do
    [[ -z "$monitor" ]] && continue
    # Run capture in background for parallel processing
    capture_monitor "$monitor" &
    pids+=($!)
done

# Wait for all captures to complete
for pid in "${pids[@]}"; do
    wait "$pid" && captured_count=$((captured_count + 1)) || true
done

# Warn if no screenshots were captured, but continue anyway (hyprlock will use color fallback)
if [[ $captured_count -eq 0 ]]; then
    echo "Warning: No screenshots were captured. Hyprlock will use color fallback." >&2
fi

# Generate dynamic hyprlock config with per-monitor backgrounds
# Copy base config and add per-monitor background blocks
if [[ -f "$HYPRLOCK_CONFIG" ]]; then
    # Read the base config and generate per-monitor backgrounds
    {
        # Include base config but skip existing background blocks
        awk '/^background \{/,/^\}/ {next} {print}' "$HYPRLOCK_CONFIG"
        
        # Add per-monitor background blocks
        echo ""
        echo "####################"
        echo "### PER-MONITOR BACKGROUNDS (DYNAMIC) ###"
        echo "####################"
        for monitor in $monitors; do
            [[ -z "$monitor" ]] && continue
            echo ""
            echo "background {"
            echo "    monitor = $monitor"
            echo "    path = $LOCKSCREEN_DIR/${monitor}.png"
            # Use more blur passes if not pre-blurring, otherwise use fewer
            if [[ "$USE_PRE_BLUR" == "1" ]]; then
                echo "    blur_passes = 1"
            else
                echo "    blur_passes = 3"
            fi
            echo "    color = \$base"
            echo "}"
        done
    } > "$TEMP_CONFIG"
    
    # Verify config was created
    if [[ ! -f "$TEMP_CONFIG" ]]; then
        echo "Error: Failed to create temporary config file" >&2
        hyprlock
        exit 1
    fi
    
    # Lock the screen with the dynamic config
    # Note: Don't clean up temp config immediately - hyprlock needs it while running
    if command -v hyprlock >/dev/null 2>&1; then
        # Run hyprlock (it will block until unlocked)
        # Use exec to replace the shell process with hyprlock
        exec hyprlock -c "$TEMP_CONFIG"
        # Clean up temp config after hyprlock exits (shouldn't reach here)
        rm -f "$TEMP_CONFIG"
    else
        echo "Error: hyprlock command not found" >&2
        rm -f "$TEMP_CONFIG"
        exit 1
    fi
else
    # Fallback to default hyprlock if config not found
    echo "Warning: Hyprlock config not found at $HYPRLOCK_CONFIG, using default" >&2
    hyprlock
fi

#!/usr/bin/env bash
# Lock screen with blurred screenshot background per monitor
# Dynamically detects all monitors, captures each one, applies blur, and locks with hyprlock
set -eo pipefail

LOCKSCREEN_DIR="/tmp/hyprlock"
# Use hyprlock's built-in blur instead of pre-blurring (much faster)
# Set to 1 to use ImageMagick pre-blur (slower but more control)
USE_PRE_BLUR="${USE_PRE_BLUR:-0}"
BLUR_INTENSITY="${BLUR_INTENSITY:-5}"  # Only used if USE_PRE_BLUR=1
LOCK_OVERLAY_DIR="${LOCK_OVERLAY_DIR:-$HOME/.config/hypr/lock-frames}"
LOCK_OVERLAY_FPS="${LOCK_OVERLAY_FPS:-16}"
LOCK_OVERLAY_CROSSFADE_MS="${LOCK_OVERLAY_CROSSFADE_MS:-45}"
LOCK_OVERLAY_SCRIPT="$HOME/.dotfiles/hyprland/hypr/scripts/lock_overlay_frame.sh"
LOCK_BG_BRIGHTNESS="${LOCK_BG_BRIGHTNESS:-0.87}"
LOCK_BG_CONTRAST="${LOCK_BG_CONTRAST:-0.95}"
LOCK_BG_VIBRANCY="${LOCK_BG_VIBRANCY:-0.22}"
LOCK_BG_NOISE="${LOCK_BG_NOISE:-0.014}"
LOCK_DYNAMIC_ACCENT="${LOCK_DYNAMIC_ACCENT:-1}"  ##### MAKE THE COLORS MATCH THE BACKGROUND! #####

accent_base_hex=""
accent_alt_hex=""
accent_base_rgb=""
accent_alt_rgb=""

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

extract_hex_from_image() {
    local image_path="$1"
    [[ -f "$image_path" ]] || return 1
    command -v convert >/dev/null 2>&1 || return 1

    local sampled_hex=""
    sampled_hex=$(convert "$image_path" -resize 1x1\! -format '%[hex:p{0,0}]' info:- 2>/dev/null | tr '[:lower:]' '[:upper:]')
    [[ "$sampled_hex" =~ ^[0-9A-F]{6}$ ]] || return 1

    printf '%s\n' "$sampled_hex"
}

tune_hex_color() {
    local base_hex="$1"
    local modulate_args="${2:-135,180,100}"
    [[ -n "$base_hex" ]] || return 1
    command -v convert >/dev/null 2>&1 || return 1

    local tuned_hex=""
    tuned_hex=$(convert "xc:#$base_hex" -modulate "$modulate_args" -format '%[hex:p{0,0}]' info:- 2>/dev/null | tr '[:lower:]' '[:upper:]')
    [[ "$tuned_hex" =~ ^[0-9A-F]{6}$ ]] || return 1

    printf '%s\n' "$tuned_hex"
}

hex_to_rgb_csv() {
    local hex="$1"
    [[ "$hex" =~ ^[0-9A-Fa-f]{6}$ ]] || return 1

    local red=$((16#${hex:0:2}))
    local green=$((16#${hex:2:2}))
    local blue=$((16#${hex:4:2}))

    printf '%d, %d, %d\n' "$red" "$green" "$blue"
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

if [[ "$LOCK_DYNAMIC_ACCENT" == "1" ]] && command -v convert >/dev/null 2>&1; then
    for monitor in $monitors; do
        [[ -z "$monitor" ]] && continue
        if [[ -f "$LOCKSCREEN_DIR/${monitor}.png" ]]; then
            accent_base_hex=$(extract_hex_from_image "$LOCKSCREEN_DIR/${monitor}.png" || echo "")
            [[ -n "$accent_base_hex" ]] && break
        fi
    done

    if [[ -n "$accent_base_hex" ]]; then
        accent_base_hex=$(tune_hex_color "$accent_base_hex" "135,180,100" || echo "$accent_base_hex")
        accent_alt_hex=$(tune_hex_color "$accent_base_hex" "115,140,100" || echo "$accent_base_hex")
        accent_base_rgb=$(hex_to_rgb_csv "$accent_base_hex" || echo "")
        accent_alt_rgb=$(hex_to_rgb_csv "$accent_alt_hex" || echo "")
    fi
fi

overlay_enabled=0
overlay_reload_ms=0
if [[ -x "$LOCK_OVERLAY_SCRIPT" ]] && [[ -d "$LOCK_OVERLAY_DIR" ]]; then
    if find "$LOCK_OVERLAY_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.webp' -o -iname '*.jpg' -o -iname '*.jpeg' \) | read -r _; then
        overlay_enabled=1
        if [[ "$LOCK_OVERLAY_FPS" =~ ^[0-9]+$ ]] && [[ "$LOCK_OVERLAY_FPS" -gt 0 ]]; then
            overlay_reload_ms=$((1000 / LOCK_OVERLAY_FPS))
        fi
    fi
fi

# Generate dynamic hyprlock config with per-monitor backgrounds
# Copy base config and add per-monitor background blocks
if [[ -f "$HYPRLOCK_CONFIG" ]]; then
    # Read the base config and generate per-monitor backgrounds
    {
        # Include base config but skip existing background blocks. Inject dynamic
        # accent variables right after the theme source line so widgets can use them.
        awk -v accent_base_hex="$accent_base_hex" -v accent_alt_hex="$accent_alt_hex" -v accent_base_rgb="$accent_base_rgb" -v accent_alt_rgb="$accent_alt_rgb" '
            /^background \{/ { skip = 1 }
            skip && /^\}/ { skip = 0; next }
            skip { next }
            /^\$accent = / && accent_base_hex != "" { next }
            /^\$accent_alt = / && accent_alt_hex != "" { next }
            /^\$lock_accent_border = / && accent_base_rgb != "" { next }
            /^\$lock_accent_ring = / && accent_base_rgb != "" { next }
            /^\$lock_accent_focus = / && accent_base_rgb != "" { next }
            { print }
            /^source = / {
                if (accent_base_hex != "") {
                    printf "$accent = rgb(%s)\n", accent_base_hex
                    printf "$accent_alt = rgb(%s)\n", accent_alt_hex != "" ? accent_alt_hex : accent_base_hex
                    printf "$lock_accent_border = rgba(%s, 0.30)\n", accent_base_rgb
                    printf "$lock_accent_ring = rgba(%s, 0.16)\n", accent_base_rgb
                    printf "$lock_accent_focus = rgba(%s, 0.85)\n", accent_base_rgb
                }
            }
        ' "$HYPRLOCK_CONFIG"
        
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
            echo "    zindex = -2"
            # Use more blur passes if not pre-blurring, otherwise use fewer
            if [[ "$USE_PRE_BLUR" == "1" ]]; then
                echo "    blur_passes = 1"
            else
                echo "    blur_passes = 3"
            fi
            echo "    brightness = $LOCK_BG_BRIGHTNESS"
            echo "    contrast = $LOCK_BG_CONTRAST"
            echo "    vibrancy = $LOCK_BG_VIBRANCY"
            echo "    noise = $LOCK_BG_NOISE"
            echo "    color = \$base"
            echo "}"

            if [[ $overlay_enabled -eq 1 ]] && [[ $overlay_reload_ms -gt 0 ]]; then
                echo ""
                echo "background {"
                echo "    monitor = $monitor"
                echo "    path = cmd[$LOCK_OVERLAY_SCRIPT \"$LOCK_OVERLAY_DIR\" \"$monitor\"]"
                echo "    reload_time = $overlay_reload_ms"
                echo "    crossfade_time = $LOCK_OVERLAY_CROSSFADE_MS"
                echo "    zindex = -1"
                echo "}"
            fi
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

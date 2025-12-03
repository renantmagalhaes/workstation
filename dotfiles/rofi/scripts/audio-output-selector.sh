#!/usr/bin/env bash

# Rofi-based audio output device selector
# Lists all available audio sinks and profiles, allows selecting one
# Moves all active audio streams to the selected device/profile

set -euo pipefail

# Function to get profile sink name (predicts sink name from profile)
get_profile_sink_name() {
    local card_name="$1"
    local profile_name="$2"
    
    # Extract device identifier from card name (e.g., "usb-Sony_INZONE_Buds-00" from "alsa_card.usb-Sony_INZONE_Buds-00")
    local device_id
    device_id=$(echo "$card_name" | sed 's/alsa_card\.//')
    
    # Map profile to sink name pattern
    case "$profile_name" in
        output:analog-stereo*)
            echo "alsa_output.${device_id}.analog-stereo"
            ;;
        output:iec958-stereo*)
            echo "alsa_output.${device_id}.iec958-stereo"
            ;;
        *)
            # Try to construct from profile name
            local profile_suffix
            profile_suffix=$(echo "$profile_name" | sed 's/output://' | sed 's/+.*//')
            echo "alsa_output.${device_id}.${profile_suffix}"
            ;;
    esac
}

# Get list of INZONE Buds profiles only (user only cares about this device)
# Filter to only show profiles with sources: 0 (no microphone/input)
formatted_profiles=$(pactl list cards | awk '
    BEGIN {
        card_name = ""
        card_desc = ""
        in_profiles = 0
        is_inzone = 0
    }
    /^[[:space:]]*Name: / {
        card_name = $2
        card_desc = ""
        # Only process INZONE Buds
        is_inzone = (card_name ~ /INZONE|Sony.*Buds/)
    }
    /^[[:space:]]*Description:/ {
        card_desc = substr($0, index($0, ":") + 2)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", card_desc)
        # Also check description for INZONE
        if (!is_inzone) {
            is_inzone = (card_desc ~ /INZONE|Sony.*Buds/i)
        }
    }
    /^[[:space:]]*Profiles:/ {
        in_profiles = 1
        next
    }
    in_profiles && /^[[:space:]]*output:/ && is_inzone {
        # Only show profiles with sources: 0 (no microphone/input)
        # and that have sinks (audio output)
        if ($0 ~ /sources: 0/ && $0 ~ /sinks: [1-9]/) {
            # Extract profile name - format is "output:analog-stereo: Description..."
            match($0, /output:[^:]+:/)
            if (RSTART > 0) {
                # Extract just the profile name part (without the trailing colon)
                profile_name = substr($0, RSTART, RLENGTH - 1)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", profile_name)
                
                # Extract description (everything after profile name and colon, before the parenthesis)
                desc_start = RSTART + RLENGTH + 1
                rest = substr($0, desc_start)
                paren_pos = index(rest, "(")
                if (paren_pos > 0) {
                    profile_desc = substr(rest, 1, paren_pos - 1)
                } else {
                    profile_desc = rest
                }
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", profile_desc)
                
                # Create a cleaner display name
                display_name = "INZONE Buds"
                if (profile_desc ~ /Analog Stereo/) {
                    display_name = display_name " - Analog"
                } else if (profile_desc ~ /Digital Stereo|IEC958/) {
                    display_name = display_name " - Digital (Gaming)"
                } else {
                    display_name = display_name " - " profile_desc
                }
                print display_name " | PROFILE:" card_name ":" profile_name
            }
        }
    }
    /^[[:space:]]*Active Profile:/ {
        in_profiles = 0
    }
    /^$/ {
        if (!in_profiles) {
            card_name = ""
            card_desc = ""
            is_inzone = 0
        }
    }
')

# Show all sinks (one entry per device)
# Extract device name from description and show one per unique device
formatted_sinks=$(pactl list sinks short | while IFS=$'\t' read -r _ name description state rest; do
    description=$(echo "$description" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -z "$description" ] || [ "$description" = " " ]; then
        # Fallback: extract from sink name
        if echo "$name" | grep -q "INZONE"; then
            description="INZONE Buds"
        elif echo "$name" | grep -q "hdmi"; then
            description="HDMI"
        elif echo "$name" | grep -q "usb"; then
            description="USB Audio"
        else
            description="$name"
        fi
    fi
    
    # Extract device name - remove technical details
    # Examples: "INZONE Buds Analog Stereo" -> "INZONE Buds"
    #           "HDMI / DisplayPort" -> "HDMI"
    clean_desc=$(echo "$description" | sed 's/[[:space:]]*Output$//' | sed 's/[[:space:]]*Analog Stereo$//' | sed 's/[[:space:]]*Digital Stereo.*$//' | sed 's/[[:space:]]*IEC958.*$//' | sed 's/[[:space:]]*\(IEC958\).*$//' | sed 's/ at usb.*$//' | sed 's/ at pci.*$//' | sed 's/ \/ .*$//')
    
    # Simplify common device names
    if echo "$clean_desc" | grep -qi "inzone"; then
        clean_desc="INZONE Buds"
    elif echo "$clean_desc" | grep -qiE "hdmi|displayport"; then
        clean_desc="HDMI"
    elif echo "$clean_desc" | grep -qiE "usb.*audio|c-media"; then
        clean_desc="USB Audio"
    fi
    
    # If still empty, use a fallback
    if [ -z "$clean_desc" ] || [ "$clean_desc" = " " ]; then
        clean_desc="Audio Device"
    fi
    
    # Prefer RUNNING sinks, but show all devices
    priority=0
    if [ "$state" = "RUNNING" ]; then
        priority=1
    elif [ "$state" = "IDLE" ]; then
        priority=2
    else
        priority=3
    fi
    
    echo "$priority|$clean_desc | SINK:$name"
done | sort -t'|' -k1,1n -k2,2 | sed 's/^[0-9]|//' | awk -F'|' '!seen[$2]++ {print $2}')

# Combine sinks and profiles, with sinks first
all_options=$(echo -e "$formatted_sinks\n$formatted_profiles" | grep -v '^$' | sort -u)

if [ -z "$all_options" ]; then
    notify-send "Audio Output Selector" "No audio outputs found"
    exit 1
fi

# Show rofi menu and get selection
selected=$(echo "$all_options" | rofi -dmenu -i -p "Select Audio Output:" -no-custom)

if [ -z "$selected" ]; then
    exit 0
fi

# Check if it's a profile or a sink
if echo "$selected" | grep -q "PROFILE:"; then
    # It's a profile selection - need to switch profile first
    profile_info=$(echo "$selected" | awk -F'PROFILE:' '{print $2}')
    # Format: alsa_card.usb-Sony_INZONE_Buds-00:output:iec958-stereo
    # or: alsa_card.usb-Sony_INZONE_Buds-00:pro-audio
    # Card names always start with "alsa_card." and don't contain colons
    # Profiles start with "output:", "input:", "pro-audio", or "off"
    # Extract card name (everything before the first colon)
    card_name=$(echo "$profile_info" | cut -d':' -f1)
    # Extract profile name (everything after the first colon, restoring any colons in the profile name)
    # If there are multiple colons, we need to join them back
    if echo "$profile_info" | grep -q ':.*:'; then
        # Profile name contains colons (e.g., output:iec958-stereo)
        profile_name=$(echo "$profile_info" | sed 's/^[^:]*://')
    else
        # Profile name is simple (e.g., pro-audio, off)
        profile_name=$(echo "$profile_info" | cut -d':' -f2)
    fi
    
    # Switch card to the selected profile
    if ! pactl set-card-profile "$card_name" "$profile_name" 2>/dev/null; then
        notify-send "Audio Output Selector" "Failed to switch profile: $profile_name"
        exit 1
    fi
    
    # Wait a moment for the sink to be created
    sleep 0.8
    
    # Extract device identifier from card name (e.g., "usb-Sony_INZONE_Buds-00")
    device_id=$(echo "$card_name" | sed 's/alsa_card\.//')
    
    # Find the sink that belongs to this card
    # Try predicted name first
    predicted_sink=$(get_profile_sink_name "$card_name" "$profile_name")
    
    # Check if predicted sink exists (check both RUNNING and SUSPENDED sinks)
    if pactl list sinks short | grep -q "[[:space:]]${predicted_sink}[[:space:]]"; then
        sink_name="$predicted_sink"
    else
        # Find any sink that matches the device ID and profile pattern
        # Look for sinks matching the device ID
        sink_name=$(pactl list sinks short | grep "$device_id" | awk '{print $2}' | head -1)
        
        # If still not found, try to match by profile type in sink name
        if [ -z "$sink_name" ]; then
            profile_type=$(echo "$profile_name" | sed 's/output://' | sed 's/+.*//')
            sink_name=$(pactl list sinks short | grep "$device_id" | grep "$profile_type" | awk '{print $2}' | head -1)
        fi
    fi
    
    if [ -z "$sink_name" ]; then
        notify-send "Audio Output Selector" "Sink not found after switching to $profile_name. Trying again..."
        # One more attempt after a longer wait
        sleep 0.5
        sink_name=$(pactl list sinks short | grep "$device_id" | awk '{print $2}' | head -1)
    fi
    
    if [ -z "$sink_name" ]; then
        notify-send "Audio Output Selector" "Failed to find sink for $profile_name"
        exit 1
    fi
else
    # It's a direct sink selection
    sink_name=$(echo "$selected" | awk -F'SINK:' '{print $2}')
fi

if [ -z "$sink_name" ]; then
    notify-send "Audio Output Selector" "Invalid selection"
    exit 1
fi

# Get all active sink-inputs and move them to the selected sink
sink_inputs=$(pactl list short sink-inputs | awk '{print $1}')

# Move each sink-input to the selected sink
moved_count=0
if [ -n "$sink_inputs" ]; then
    for input_id in $sink_inputs; do
        if pactl move-sink-input "$input_id" "$sink_name" 2>/dev/null; then
            moved_count=$((moved_count + 1))
        fi
    done
fi

# Set the selected sink as default
pactl set-default-sink "$sink_name" 2>/dev/null || true

# Notify user
if [ $moved_count -gt 0 ]; then
    notify-send "Audio Output Selector" "Moved $moved_count stream(s) to $sink_name"
else
    notify-send "Audio Output Selector" "Set default sink to $sink_name"
fi

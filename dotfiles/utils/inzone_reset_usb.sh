#!/bin/bash

# Find Sony Inzone based on name match only
line=$(lsusb | grep -i "INZONE")
if [ -z "$line" ]; then
    line=$(lsusb | grep -i "Sony")
fi

if [ -z "$line" ]; then
    echo "Sony Inzone dongle not found in lsusb"
    exit 1
fi

echo "$line"

bus=$(echo "$line" | awk '{print $2}')
dev=$(echo "$line" | awk '{print $4}' | sed 's/://')

devpath="/dev/bus/usb/$bus/$dev"

# Query udev for the actual sysfs path that represents this USB device
sys_path=$(udevadm info -q path -n "$devpath")

if [ -z "$sys_path" ]; then
    echo "udevadm could not resolve the sysfs path"
    exit 1
fi

# Full real path in sysfs
full="/sys${sys_path}"

echo "Resolved sysfs path:"
echo "$full"

# Get the closest parent folder that represents a physical USB port
port=$(basename "$full")

echo "Resetting USB port: $port"

# Check if running as root (via pkexec), if not use sudo
if [ "$EUID" -eq 0 ]; then
    echo "$port" | tee /sys/bus/usb/drivers/usb/unbind >/dev/null
    sleep 1
    echo "$port" | tee /sys/bus/usb/drivers/usb/bind >/dev/null
else
    echo "$port" | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null
    sleep 1
    echo "$port" | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null
fi

echo "Done. Sony Inzone dongle reset."

# Wait for USB device to reinitialize and audio device to appear
echo "Waiting for audio device to initialize..."
sleep 2

# Function to set Inzone buds as default audio output
set_inzone_as_default() {
    local inzone_sink=""
    
    # Try wpctl first (PipeWire/WirePlumber)
    if command -v wpctl >/dev/null 2>&1; then
        echo "Using wpctl (PipeWire) to set audio device..."
        
        # Wait a bit more and try to find the device
        local max_attempts=5
        local attempt=0
        
        while [ $attempt -lt $max_attempts ]; do
            # Parse wpctl status: look for "INZONE Buds" in the Sinks section
            # Format: "119. INZONE Buds Analog Stereo" or "*  119. INZONE Buds Analog Stereo"
            # Extract the ID number (handles both default "*" and non-default cases)
            inzone_sink=$(wpctl status 2>/dev/null | awk '/├─ Sinks:/,/├─ Sources:/' | grep -i "inzone.*buds" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.$/) {print $i; break}}' | sed 's/[^0-9]//g')
            
            if [ -n "$inzone_sink" ] && [ "$inzone_sink" != "0" ]; then
                echo "Found Inzone audio device: $inzone_sink"
                if wpctl set-default "$inzone_sink" 2>/dev/null; then
                    echo "Set Inzone buds as default output device"
                    return 0
                fi
            fi
            
            attempt=$((attempt + 1))
            sleep 1
        done
    fi
    
    # Fallback to pactl (PulseAudio compatibility layer)
    if command -v pactl >/dev/null 2>&1; then
        echo "Using pactl to set audio device..."
        
        # Find Inzone sink - try multiple patterns
        inzone_sink=$(pactl list sinks short 2>/dev/null | grep -i "inzone\|sony.*buds" | head -1 | awk '{print $2}')
        
        if [ -z "$inzone_sink" ]; then
            # Try finding by description
            inzone_sink=$(pactl list sinks 2>/dev/null | grep -i -B5 "inzone\|sony.*buds" | grep "Sink #" | head -1 | awk '{print $2}' | sed 's/#//')
        fi
        
        if [ -n "$inzone_sink" ]; then
            echo "Found Inzone audio device: $inzone_sink"
            if pactl set-default-sink "$inzone_sink" 2>/dev/null; then
                echo "Set Inzone buds as default output device"
                return 0
            fi
        fi
    fi
    
    echo "Warning: Could not find or set Inzone buds as audio output device"
    echo "You may need to manually select it from your audio settings"
    return 1
}

# Set Inzone buds as default audio output
set_inzone_as_default

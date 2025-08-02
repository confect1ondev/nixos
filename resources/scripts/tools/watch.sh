#!/usr/bin/env bash

# Iterate through video devices from /dev/video0 to /dev/video10
for i in $(seq 0 10); do
    device="/dev/video$i"
    # Check if the device exists and is accessible
    if [ -e "$device" ] && [ -r "$device" ]; then
        echo "Found video input at $device"
        # Play the video
        ffplay "$device"
        exit 0
    fi
done

# If no suitable device is found
echo "Error: Could not find suitable video input."
exit 1

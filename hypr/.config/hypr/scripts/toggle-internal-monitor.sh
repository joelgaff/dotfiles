#!/bin/bash

# Toggle the internal display (eDP-1) on/off.
# When disabled, workspaces 1-5 move to the external DP monitor.
# When re-enabled, workspaces 1-5 move back to eDP-1.

INTERNAL="eDP-1"

# Find the active external DP monitor
EXTERNAL=$(hyprctl monitors -j | grep -o '"name": "DP-[0-9]*"' | head -1 | cut -d'"' -f4)

if [ -z "$EXTERNAL" ]; then
    notify-send "No external monitor" "Connect an external monitor before toggling."
    exit 1
fi

# Check if eDP-1 is currently active
ACTIVE=$(hyprctl monitors -j | grep -o "\"name\": \"$INTERNAL\"")

if [ -n "$ACTIVE" ]; then
    # Disable internal monitor
    hyprctl keyword monitor "$INTERNAL, disable"
    sleep 0.5
    for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i $EXTERNAL"
    done
    sudo systemctl mask fprintd.service
    sudo systemctl stop fprintd.service
    notify-send "Internal display off" "Workspaces moved to $EXTERNAL"
else
    # Re-enable internal monitor
    hyprctl keyword monitor "$INTERNAL, 2880x1920@120, auto-center-down, 2"
    sleep 0.5
    for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i $INTERNAL"
    done
    sudo systemctl unmask fprintd.service
    notify-send "Internal display on" "Workspaces moved back to $INTERNAL"
fi

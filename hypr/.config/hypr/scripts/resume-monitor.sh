#!/bin/bash

# Re-enable monitors after sleep/hibernate resume.
# Polls until the DRM subsystem has re-detected eDP-1, then reloads
# the full Hyprland config to re-apply all monitor rules.

for _ in $(seq 1 10); do
    if hyprctl monitors all -j 2>/dev/null | grep -q '"name": "eDP-1"'; then
        hyprctl reload
        hyprctl dispatch dpms on
        exit 0
    fi
    sleep 1
done

# Fallback after 10s: try reload anyway
hyprctl reload
hyprctl dispatch dpms on

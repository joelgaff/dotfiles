#!/bin/bash
# Manually toggle internal display (eDP-1). Delegates to Omarchy's command
# and adds fprintd state coupling + explicit workspace placement.

TOGGLE_FLAG="$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua"
LAYOUT="$HOME/.config/hypr/scripts/workspace-layout.sh"

if [ -f "$TOGGLE_FLAG" ]; then
  omarchy-hyprland-monitor-internal on
  sudo systemctl unmask fprintd.service
  # Internal is back: 6-10 belong on it again.
  sleep 0.5
  "$LAYOUT"
else
  if ! omarchy-hyprland-monitor-external-active; then
    notify-send "No external monitor" "Connect an external monitor before toggling."
    exit 1
  fi
  omarchy-hyprland-monitor-internal off
  sleep 0.5
  # Only 1-5 are placed here; with the internal panel dark, the layout script
  # leaves 6-10 wherever Hyprland relocated them.
  "$LAYOUT"
  sudo systemctl mask fprintd.service
  sudo systemctl stop fprintd.service
fi

#!/bin/bash
# Manually toggle internal display (eDP-1). Delegates to Omarchy's command
# and adds fprintd state coupling + explicit workspace placement.

TOGGLE_FLAG="$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua"

if [ -f "$TOGGLE_FLAG" ]; then
  omarchy-hyprland-monitor-internal on
  sudo systemctl unmask fprintd.service
else
  EXTERNAL=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("DP-")).name' | head -1)
  if [ -z "$EXTERNAL" ]; then
    notify-send "No external monitor" "Connect an external monitor before toggling."
    exit 1
  fi
  omarchy-hyprland-monitor-internal off
  sleep 0.5
  for i in 1 2 3 4 5; do
    hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$i\", monitor = \"$EXTERNAL\" })"
  done
  sudo systemctl mask fprintd.service
  sudo systemctl stop fprintd.service
fi

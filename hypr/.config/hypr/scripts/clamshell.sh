#!/bin/bash
# Lid-switch handler. Delegates to Omarchy's monitor command and adds:
#  - fprintd mask/unmask coupled to internal-display state
#  - undocked fallback: lock + suspend-then-hibernate

case "$1" in
  close)
    if omarchy-hw-external-monitors; then
      omarchy-hyprland-monitor-internal off
      sudo systemctl mask fprintd.service
      sudo systemctl stop fprintd.service
    else
      # No external — going in a bag. Suspend, then hibernate after 30min.
      loginctl lock-session
      sleep 1
      systemctl suspend-then-hibernate
    fi
    ;;
  open)
    omarchy-hyprland-monitor-internal on
    sudo systemctl unmask fprintd.service
    ;;
esac

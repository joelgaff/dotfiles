#!/bin/bash
# Re-apply the docked workspace layout whenever a monitor comes or goes.
#
# Omarchy ships omarchy-hyprland-monitor-watch, but that one owns clamshell and
# modeless recovery and never touches workspace placement, so this is a separate
# listener on the same socket rather than an edit to a packaged binary.

set -uo pipefail

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
LAYOUT="$HOME/.config/hypr/scripts/workspace-layout.sh"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/hypr-workspace-layout.lock"

# Hyprland reshuffles workspaces itself as a monitor appears, and the new output
# is not immediately ready to receive them. Settle, then re-apply a couple more
# times so the last word is ours. flock keeps overlapping events from racing.
apply() {
  (
    flock -n 9 || exit 0
    for delay in 1 2 4; do
      sleep "$delay"
      "$LAYOUT"
    done
  ) 9>"$LOCK" &
}

apply

while read -r event; do
  case "$event" in
    monitoradded\>\>* | monitoraddedv2\>\>* | monitorremoved\>\>* | monitorremovedv2\>\>*)
      apply
      ;;
  esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET")

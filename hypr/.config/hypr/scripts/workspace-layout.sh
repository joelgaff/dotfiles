#!/bin/bash
# Docked workspace layout: 1-5 on the external monitor, 6-10 on the internal
# panel. The static rules in hosts/<hostname>.lua can only name one external
# port, so this reconciles against whichever external is actually attached.
#
# Idempotent and safe to run on every monitor event; a no-op when undocked,
# where everything falls back to the internal panel on its own.

set -uo pipefail

INTERNAL=$(omarchy-hyprland-monitor-laptop)

# Enabled monitors only -- a disabled internal panel (clamshell) must not be a
# move target, and a powered-off external must not be picked as "the" external.
monitors=$(hyprctl monitors -j)

EXTERNAL=$(jq -r --arg internal "$INTERNAL" \
  'map(select(.name != $internal)) | .[0].name // empty' <<<"$monitors")

# Undocked: Hyprland already has everything on the one display.
[[ -z $EXTERNAL ]] && exit 0

internal_active=$(jq -r --arg internal "$INTERNAL" \
  'any(.name == $internal) | tostring' <<<"$monitors")

# Moving a workspace that does not exist yet is an error, not a no-op, so only
# touch the ones Hyprland currently knows about.
mapfile -t existing < <(hyprctl workspaces -j | jq -r '.[].id')

move_if_exists() {
  local ws=$1 target=$2
  for id in "${existing[@]}"; do
    [[ $id == "$ws" ]] || continue
    # Quattro's dispatch is Lua; the old "moveworkspacetomonitor 1 DP-3" form
    # is a parse error rather than a fallback.
    hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$target\" })" >/dev/null
    return
  done
}

for ws in 1 2 3 4 5; do
  move_if_exists "$ws" "$EXTERNAL"
done

# With the lid shut the internal panel is disabled and Hyprland owns placement;
# forcing 6-10 onto it would strand them on a dark display.
if [[ $internal_active == "true" ]]; then
  for ws in 6 7 8 9 10; do
    move_if_exists "$ws" "$INTERNAL"
  done
fi

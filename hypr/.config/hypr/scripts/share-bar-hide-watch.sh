#!/bin/bash
# Hide Chromium's "<site> is sharing your screen." bar.
#
# Omarchy's window rule (title ".*is sharing.*" -> special silent) only fires
# when the window maps. Chromium sometimes sets the title after mapping, the
# rule misses, and the bar sits on screen holding focus. This listener catches
# the title change too and moves the bar away without taking focus.

set -uo pipefail

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

hide() {
  hyprctl dispatch "hl.dsp.window.move({ window = \"address:0x$1\", workspace = \"special:sharebar\", follow = false })" >/dev/null
}

while read -r event; do
  case "$event" in
    windowtitlev2\>\>*"is sharing your screen"* | openwindow\>\>*"is sharing your screen"*)
      payload="${event#*>>}"
      hide "${payload%%,*}"
      ;;
  esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET")

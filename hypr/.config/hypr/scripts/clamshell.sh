#!/bin/bash

if [ "$1" = "close" ]; then
    EXTERNAL=$(hyprctl monitors -j | grep -o '"name": "DP-[0-9]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$EXTERNAL" ]; then
        hyprctl keyword monitor "eDP-1, disable"
        sleep 0.5
        for i in 1 2 3 4 5; do
            hyprctl dispatch moveworkspacetomonitor "$i $EXTERNAL"
        done
    fi
elif [ "$1" = "open" ]; then
    hyprctl keyword monitor "eDP-1, 2880x1920@120, auto, 2"
    sleep 0.5
    for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i eDP-1"
    done
fi

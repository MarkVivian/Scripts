#!/bin/bash

# Define monitor names
MON_LEFT="DP-2"
MON_CENTER="DP-1"

# Check that both external monitors are connected
connected_left=$(xrandr | grep "^${MON_LEFT} connected")
connected_center=$(xrandr | grep "^${MON_CENTER} connected")

if [[ -z "$connected_left" || -z "$connected_center" ]]; then
  echo "One or both external monitors not detected. Exiting."
  exit 1
fi

# (Re)create the 1080p mode on DP-2 if missing
if ! xrandr | grep -q "1920x1080_60.00"; then
  xrandr --newmode "1920x1080_60.00" \
    173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
  xrandr --addmode "${MON_LEFT}" "1920x1080_60.00"
fi

# Configure monitors:
#  - DP-2: 23" in portrait, far left
#  - DP-1: 27" primary, center
#  - eDP-1: laptop panel, OFF
xrandr \
  --output "${MON_LEFT}"  --mode 1920x1080_60.00 --rotate left  --pos 0x0 \
  --output "${MON_CENTER}" --mode 2560x1440       --primary      --pos 1080x0 \
  --output eDP-1           --off

notify-send "secondary monitor configuration" "Monitor layout applied successfully."


#!/bin/bash

# Check if waybar is running
if pgrep -x "waybar" >/dev/null; then
    # If running, kill the waybar process
    killall "waybar"
else
    # If not running, start waybar
    waybar &
fi

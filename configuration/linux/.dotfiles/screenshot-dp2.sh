#!/bin/bash

FILENAME="screenshot-$(date '+%Y%m%d-%H%M%S').png"
SAVE_DIR="$HOME/Pictures/"
FULL_PATH="$SAVE_DIR/$FILENAME"

mkdir -p "$SAVE_DIR"
canberra-gtk-play --file="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga" &

grim -o DP-2 "$FULL_PATH"

if [[ -f "$FULL_PATH" ]]; then
  notify-send "Screenshot salva" "$FULL_PATH"
else
  notify-send "Erro" "Não foi possível tirar o screenshot."
fi

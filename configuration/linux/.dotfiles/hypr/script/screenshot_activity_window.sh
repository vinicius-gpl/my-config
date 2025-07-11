#!/bin/bash

FILENAME="screenshot-$(date '+%Y%m%d-%H%M%S').png"
SAVE_DIR="$HOME/Pictures/Screenshot/"
FULL_PATH="$SAVE_DIR/$FILENAME"
TITLE_FILTER="hyprctl activewindow ~"
CLASS_FILTER="kitty-dropterm"

# Limpar as notificações e dar um delay para notificação não aparecer no print.
swaync-client -C
sleep 0.3

geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

if [ -z "$geometry" ]; then
    notify-send -u critical -i dialog-error "Erro" "Janela com título ~$TITLE_FILTER~ e class ~$CLASS_FILTER~ não encontrada."
    exit 1
fi

mkdir -p "$SAVE_DIR"

grim -g "$geometry" "$FULL_PATH"
wl-copy <"$FULL_PATH"

if [[ -f "$FULL_PATH" ]]; then
    # Som de camera para retorno de que foi tirado o print.
    canberra-gtk-play --file="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga" &
    notify-send -i "$FULL_PATH" "🖼️ Print perfeito, chefia!" "Salvo em:\n$FULL_PATH"
else
    notify-send -u critical -i dialog-error "Erro" "Não foi possível tirar o screenshot."
fi

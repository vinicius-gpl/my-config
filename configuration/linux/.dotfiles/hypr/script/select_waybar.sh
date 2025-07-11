#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
STYLECSS="$WAYBAR_DIR/style.css"
CONFIG="$WAYBAR_DIR/config.jsonc"
ASSETS="$WAYBAR_DIR/assets"
THEMES="$WAYBAR_DIR/themes"

menu() {
    find "${ASSETS}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}

main() {
    pkill wofi
    choice=$(menu | wofi -c ~/.config/wofi/custom/waybar -s ~/.config/wofi/custom/style-waybar.css --show dmenu --prompt " Select Waybar (Scroll with Arrows)" -n)

    selected_waybar="${choice#img:}"
    [ -z "$selected_waybar" ] && exit 1
    echo $selected_waybar

    if [[ "$selected_waybar" == "$ASSETS/experimental.png" ]]; then
        cat $THEMES/experimental/style-experimental.css >$STYLECSS
        cat $THEMES/experimental/config-experimental.jsonc >$CONFIG
        pkill waybar && waybar

    elif [[ "$selected_waybar" == "$ASSETS/main.png" ]]; then
        cat $THEMES/default/style-default.css >$STYLECSS
        cat $THEMES/default/config-default.jsonc >$CONFIG
        pkill waybar && waybar

    elif [[ "$selected_waybar" == "$ASSETS/line.png" ]]; then
        cat $THEMES/line/style-line.css >$STYLECSS
        cat $THEMES/line/config-line.jsonc >$CONFIG
        pkill waybar && waybar

    elif [[ "$selected_waybar" == "$ASSETS/zen.png" ]]; then
        cat $THEMES/zen/style-zen.css >$STYLECSS
        cat $THEMES/zen/config-zen.jsonc >$CONFIG
        pkill waybar && waybar
    fi
}

main

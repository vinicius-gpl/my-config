# --------------------------------------------------
# Screenshot rápido para tela que está ativa
# --------------------------------------------------

# Filename 
source ~/.config/ml4w/settings/screenshot-filename.sh

# Caminho para prints
source ~/.config/ml4w/settings/screenshot-folder.sh

# Caminho do som
sound_camera=/usr/share/sounds/freedesktop/stereo/camera-shutter.oga

takescreenshot() {
grimblast --notify save active $NAME 
    if [ -f $HOME/$NAME ]; then
        if [ -d $screenshot_folder ]; then 
            paplay "$sound_camera" &
            mv $HOME/$NAME $screenshot_folder/
        fi
    fi
}

takescreenshot

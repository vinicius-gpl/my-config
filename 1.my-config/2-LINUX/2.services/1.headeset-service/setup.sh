#!/bin/bash

echo "Movendo arquivo de shell para o diretório de scripts"


# 99-set-headset-max-volume.rules
# flag-headset-plugged.sh
# set-headset-max-volume.service
# set-headset-max-volume.sh

directory_to_shell="/usr/lib/systemd/scripts"
directory_to_service="/usr/lib/systemd/system"
directory_to_rule="/etc/udev/rules.d"
current_dir="$(pwd)"

if [ -d "$directory_to_shell" ]; then
    echo "Diretório encontrado, movendo shell"

    if cp "$current_dir/set-headset-max-volume.sh" "$directory_to_shell/set-headset-max-volume.sh"; then
        echo "Arquivo set-headset-max-volume.sh copiado com sucesso!"
    else
        echo "Erro ao copiar set-headset-max-volume.sh"
    fi

    if cp "$current_dir/flag-headset-plugged.sh" "$directory_to_shell/flag-headset-plugged.sh"; then
        echo "Arquivo flag-headset-plugged.sh copiado com sucesso!"
    else    
        echo "Erro ao copiar arquivo flag-headset-plugged.sh!"
    fi

    if [ -d "$directory_to_service" ]; then
        echo "Diretório encontrado, movendo serviço"

        if cp "$current_dir/set-headset-max-volume.service" "$directory_to_service/set-headset-max-volume.service"; then
            echo "Arquivo set-headset-max-volume.service copiado com sucesso!"

            sudo systemctl daemon-reexec
            sudo systemctl daemon-reload
    
            sudo systemctl enable --now set-headset-max-volume.service
            systemctl start set-headset-max-volume.service
        else
            echo "Erro ao copiar set-headset-max-volume.service"
        fi
    else
        echo "Erro ao mover para $directory_to_service"
    fi
else
    echo "Erro ao mover para $directory_to_shell"
fi

if [ -d "$directory_to_rule" ]; then
    echo "Diretório encontrado, movendo rule"

    if cp "$current_dir/99-set-headset-max-volume.rules" "$directory_to_rule/99-set-headset-max-volume.rules"; then
        echo "Arquivo de 99-set-headset-max-volume.rules copiado com sucesso!"

        sudo udevadm control --reload-rules
        sudo udevadm trigger
    else   
        echo "Erro ao copiar 99-set-headset-max-volume.rules"
    fi
else 
    echo "Diretório não encontrado para mover o 99-set-headset-max-volume.rules"
fi

systemctl status set-headset-max-volume.service
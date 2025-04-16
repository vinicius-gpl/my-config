#!/bin/bash

echo "Movendo arquivos de configuração para os diretórios corretos..."

# Diretórios de destino
directory_to_shell="$HOME/.config/systemd/user/scripts"
directory_to_service="$HOME/.config/systemd/user"
directory_to_rule="/etc/udev/rules.d"
current_dir="$(pwd)"

# Scripts
if [ -d "$directory_to_shell" ]; then
    echo "-> Diretório de scripts encontrado."

    cp "$current_dir/set-headset-max-volume.sh" "$directory_to_shell/" \
        && echo "✓ Copiado: set-headset-max-volume.sh" \
        || echo "✗ Erro ao copiar set-headset-max-volume.sh"

    cp "$current_dir/flag-headset-plugged.sh" "$directory_to_shell/" \
        && echo "✓ Copiado: flag-headset-plugged.sh" \
        || echo "✗ Erro ao copiar flag-headset-plugged.sh"
else
    echo "✗ Diretório de scripts não encontrado: $directory_to_shell"
fi

# Serviço systemd
if [ -d "$directory_to_service" ]; then
    echo "-> Diretório de serviços encontrado."

    cp "$current_dir/set-headset-max-volume.service" "$directory_to_service/" \
        && echo "✓ Copiado: set-headset-max-volume.service" \
        || echo "✗ Erro ao copiar set-headset-max-volume.service"

    # Reload systemd do usuário
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
    systemctl --user enable --now set-headset-max-volume.service
else
    echo "✗ Diretório de serviços não encontrado: $directory_to_service"
fi

# Regra udev
if [ -d "$directory_to_rule" ]; then
    echo "-> Diretório de regras udev encontrado."

    cp "$current_dir/99-set-headset-max-volume.rules" "$directory_to_rule/" \
        && echo "✓ Copiado: 99-set-headset-max-volume.rules" \
        || echo "✗ Erro ao copiar regra udev"

    sudo udevadm control --reload-rules
    sudo udevadm trigger
else
    echo "✗ Diretório de regras udev não encontrado: $directory_to_rule"
fi

# Status final
echo
systemctl --user status set-headset-max-volume.service

echo
echo "✅ Setup concluído!"

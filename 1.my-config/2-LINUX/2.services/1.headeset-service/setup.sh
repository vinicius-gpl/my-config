#!/bin/bash

echo "Movendo arquivos de configuração para os diretórios corretos..."

# Diretórios de destino
directory_to_shell="$HOME/.config/systemd/user/scripts"
directory_to_service="$HOME/.config/systemd/user"
directory_to_autostart="$HOME/.config/autostart"
current_dir="$(pwd)"

# Scripts
if [ -d "$directory_to_shell" ]; then
    echo "-> Diretório de scripts encontrado."

    cp "$current_dir/set-headset-max-volume.sh" "$directory_to_shell/" \
        && echo "✓ Copiado: set-headset-max-volume.sh" \
        || echo "✗ Erro ao copiar set-headset-max-volume.sh"
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

# Autostart (arquivo .desktop)
if [ -d "$directory_to_autostart" ]; then
    echo "-> Diretório de autostart encontrado."

    cp "$current_dir/set-headset-max-volume.desktop" "$directory_to_autostart/" \
        && echo "✓ Copiado: set-headset-max-volume.desktop" \
        || echo "✗ Erro ao copiar set-headset-max-volume.desktop"
else
    echo "✗ Diretório de autostart não encontrado: $directory_to_autostart"
fi

# Status final
echo
systemctl --user status set-headset-max-volume.service

echo
echo "✅ Setup concluído!"

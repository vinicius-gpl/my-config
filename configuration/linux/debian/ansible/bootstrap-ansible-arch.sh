#!/usr/bin/env bash

set -e

echo "Iniciando bootstrap ambiente Ansible no Arch..."

# Atualiza sistema
sudo pacman -Sy --noconfirm

# Instala dependências
sudo pacman -S --needed --noconfirm openssh ansible

echo "Pacotes instalados."

# Gera chave se não existir
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Gerando chave SSH ed25519..."
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "Chave SSH já existe. Pulando geração."
fi

# Sobe ssh-agent (bash/zsh)
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "Iniciando ssh-agent..."
    eval "$(ssh-agent -s)"
fi

# Adiciona chave ao agent
ssh-add "$HOME/.ssh/id_ed25519"

echo "Chave pública:"
echo "-----------------------------------"
cat "$HOME/.ssh/id_ed25519.pub"
echo "-----------------------------------"

echo "Versões instaladas:"
ansible --version | head -n 1
ssh -V

echo "Bootstrap concluído."
echo "Copie a chave acima para o servidor (authorized_keys)."
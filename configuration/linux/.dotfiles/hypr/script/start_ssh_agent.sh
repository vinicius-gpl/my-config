#!/bin/bash
# 
export SSH_ASKPASS=/usr/bin/ksshaskpass
export DISPLAY=:0

SSH_ENV="$HOME/.ssh-agent-env"

if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" >/dev/null

    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        echo "Agente morto, reiniciando..."
        rm -f "$SSH_ENV"
        exec "$0"
    fi
else
    eval "$(ssh-agent -s)" >/dev/null
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >"$SSH_ENV"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>"$SSH_ENV"
fi

source "$SSH_ENV"

if ! ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_ed25519 | awk '{print $2}')"; then
    echo "Adicionando chave SSH com interface gráfica (ASKPASS)..."
    DISPLAY=:0 SSH_ASKPASS=/usr/bin/ksshaskpass setsid ssh-add ~/.ssh/id_ed25519 </dev/null
fi

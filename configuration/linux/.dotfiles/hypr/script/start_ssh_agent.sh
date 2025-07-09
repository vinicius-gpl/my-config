#!/bin/bash

export SSH_ASKPASS=/usr/bin/ksshaskpass
export DISPLAY=:0

SSH_ENV="$HOME/.ssh-agent-env"

if [ -f "$SSH_ENV" ]; then
  source "$SSH_ENV" >/dev/null

  if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    echo "Agente morto, iniciando novo..."
    rm -f "$SSH_ENV"
    exec $0
  fi
else
  eval $(ssh-agent -s) >/dev/null
  echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >"$SSH_ENV"
  echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>"$SSH_ENV"
fi

DISPLAY=:0 SSH_ASKPASS=/usr/bin/ksshaskpass setsid ssh-add ~/.ssh/id_ed25519 </dev/null

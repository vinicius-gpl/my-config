#!/bin/bash

# Caminho do binário askpass que você instalou
export SSH_ASKPASS=/usr/bin/ksshaskpass
export DISPLAY=:0 # necessário pra GUI funcionar

# Inicia ssh-agent
eval $(ssh-agent -s)

# Força uso do askpass mesmo sem terminal
ssh-add ~/.ssh/id_ed25519 </dev/null

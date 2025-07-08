#!/bin/bash

if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)" >~/.ssh-agent-env
fi

# In .bashrc
source "$HOME/.ssh-agent-env"

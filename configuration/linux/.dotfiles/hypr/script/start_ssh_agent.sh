#!/bin/bash

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -s > ssh-agent -s | grep -v 'echo Agent pid' > "$HOME/.ssh-agent-env"
fi

# In .bashrc
source "$HOME/.ssh-agent-env"

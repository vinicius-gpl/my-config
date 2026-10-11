#!/bin/sh
#
# Abre o zellij com o fish como shell dos paineis e, se nao houver fish, o bash.
# Chamado pelo kitty (ver `shell` em ~/.config/kitty/kitty.conf).
#
# O zellij nao expande ~ nem $HOME em `default_shell` e nao tem fallback, por
# isso o shell e resolvido aqui e passado por `options --default-shell`.

find_shell() {
  for candidate in fish /home/linuxbrew/.linuxbrew/bin/fish /usr/local/bin/fish bash /bin/bash; do
    if resolved=$(command -v "$candidate" 2>/dev/null) && [ -x "$resolved" ]; then
      echo "$resolved"
      return
    fi
  done
  echo /bin/sh
}

SHELL=$(find_shell)
export SHELL

# Sem zellij o terminal ainda abre, direto no shell.
if ! command -v zellij >/dev/null 2>&1; then
  exec "$SHELL"
fi

exec zellij attach -c main options --default-shell "$SHELL"

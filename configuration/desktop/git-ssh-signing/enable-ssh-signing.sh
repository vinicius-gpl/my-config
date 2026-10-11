#!/bin/bash
#
# Configura o git para assinar commits com a chave SSH, sem pedir senha a cada commit.
#
# Garante um agente SSH ativo em todo login (usa o do desktop se já houver um, senão
# liga um pelo systemd do usuário), guarda a senha da chave no chaveiro do login para o
# agente destravar a chave sozinho a cada login, e configura a assinatura SSH no git
# global. No fim copia a chave pública para a área de transferência, para cadastrar no
# GitHub como Signing Key.
#
# Uso:
#   ./enable-ssh-signing.sh                 # chave padrão: ~/.ssh/id_ed25519
#   ./enable-ssh-signing.sh ~/.ssh/outra    # outra chave

set -euo pipefail

# Caminho absoluto: é por ele que o agente procura a senha no chaveiro
KEY_PATH="$(realpath -s -- "${1:-$HOME/.ssh/id_ed25519}")"
PUB_PATH="$KEY_PATH.pub"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

ok() { echo "[ok] $*"; }
info() { echo "[..] $*"; }
die() {
  echo "[erro] $*" >&2
  exit 1
}

has_command() {
  command -v -- "$1" >/dev/null
}

# ssh-add -l: 0 = tem chaves, 1 = agente vazio, 2 = sem agente
agent_status() {
  local rc=0
  ssh-add -l >/dev/null 2>&1 || rc=$?
  echo "$rc"
}

for cmd in git ssh-add ssh-keygen; do
  has_command "$cmd" || die "Comando não encontrado: $cmd"
done
[[ -f "$KEY_PATH" && -f "$PUB_PATH" ]] || die "Chave não encontrada: $KEY_PATH (e $PUB_PATH)"

# O ssh ignora a chave privada se grupo ou outros puderem lê-la
if [[ "$(stat -c %a "$KEY_PATH")" != ?00 ]]; then
  chmod 600 "$KEY_PATH"
  ok "Permissão da chave privada corrigida para 600"
fi

# ---- 1. Agente SSH ----
if [[ "$(agent_status)" != 2 ]]; then
  ok "Agente SSH já está ativo ($SSH_AUTH_SOCK)"
else
  has_command systemctl && systemctl --user show-environment >/dev/null 2>&1 ||
    die "Sem agente SSH e sem systemd de usuário para ligar um."

  # Prefere o agente com chaveiro: é o único que destrava a chave sozinho no login
  if has_command secret-tool && systemctl --user cat gcr-ssh-agent.socket >/dev/null 2>&1; then
    systemctl --user enable --now gcr-ssh-agent.socket
    AGENT_SOCK_NAME=gcr/ssh
  elif systemctl --user cat ssh-agent.socket >/dev/null 2>&1; then
    systemctl --user enable --now ssh-agent.socket
  else
    # Distro sem a unit pronta: cria uma equivalente
    mkdir -p "$HOME/.config/systemd/user"
    cat >"$HOME/.config/systemd/user/ssh-agent.service" <<'EOF'
[Unit]
Description=OpenSSH key agent

[Service]
ExecStart=/usr/bin/ssh-agent -D -a %t/ssh-agent.socket
SuccessExitStatus=2

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now ssh-agent.service
  fi

  # Sessões gráficas e serviços do usuário herdam daqui a partir do próximo login
  mkdir -p "$HOME/.config/environment.d"
  AGENT_SOCK_NAME="${AGENT_SOCK_NAME:-ssh-agent.socket}"
  echo "SSH_AUTH_SOCK=\${XDG_RUNTIME_DIR}/$AGENT_SOCK_NAME" >"$HOME/.config/environment.d/ssh-agent.conf"
  export SSH_AUTH_SOCK="$RUNTIME_DIR/$AGENT_SOCK_NAME"
  systemctl --user set-environment "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"

  for _ in 1 2 3 4 5; do
    [[ "$(agent_status)" != 2 ]] && break
    sleep 0.5
  done
  [[ "$(agent_status)" != 2 ]] || die "O ssh-agent não iniciou."
  ok "ssh-agent ativado ($SSH_AUTH_SOCK)"
  NEW_AGENT=1
fi

# ---- 2. Chave destravada no agente (pede a senha da chave uma vez, e nunca mais) ----
# Assina pelo agente (-U), do mesmo jeito que o git vai fazer. Só listar com ssh-add -l
# não basta: agentes com chaveiro (GNOME/KDE) listam a chave mesmo ainda travada.
# O limite de tempo existe porque o gcr-ssh-agent não responde nunca mais se a senha
# salva no chaveiro estiver errada.
agent_signs() {
  echo teste | timeout 15 ssh-keygen -Y sign -U -n git -f "$PUB_PATH" >/dev/null 2>&1
}

key_opens_with() {
  ssh-keygen -y -P "$1" -f "$KEY_PATH" >/dev/null 2>&1
}

# Agentes do GNOME (gcr-ssh-agent e o antigo do gnome-keyring) buscam a senha da chave
# no chaveiro do login por este atributo, e o chaveiro abre junto com o login
KEYRING_ATTR=(unique "ssh-store:$KEY_PATH")

agent_uses_keyring() {
  [[ "${SSH_AUTH_SOCK:-}" == */gcr/ssh || "${SSH_AUTH_SOCK:-}" == */keyring/ssh ]] && has_command secret-tool
}

if key_opens_with ""; then
  agent_signs || ssh-add "$KEY_PATH" || die "ssh-add falhou; a chave não foi adicionada."
  ok "Chave sem senha: nada para destravar"
elif agent_uses_keyring; then
  saved="$(secret-tool lookup "${KEYRING_ATTR[@]}" 2>/dev/null || true)"
  if [[ -n "$saved" ]] && key_opens_with "$saved"; then
    ok "Senha da chave já está no chaveiro do login"
  else
    [[ -n "$saved" ]] && info "A senha salva no chaveiro está errada, vai ser substituída"
    pass=""
    for _ in 1 2 3; do
      read -rsp "Senha da chave $KEY_PATH: " pass
      echo
      key_opens_with "$pass" && break
      echo "[!!] Senha incorreta"
      pass=""
    done
    [[ -n "$pass" ]] || die "Senha da chave não confirmada; nada foi salvo."
    # Só é guardada depois de conferida com a chave
    printf %s "$pass" | secret-tool store --label="Unlock password for: $(awk '{print $3}' "$PUB_PATH")" "${KEYRING_ATTR[@]}" ||
      die "Não foi possível guardar a senha no chaveiro."
    unset pass
    ok "Senha da chave guardada no chaveiro do login"
  fi
  unset saved
  agent_signs || die "O agente não conseguiu assinar com a chave."
  ok "Agente destrava a chave sozinho a cada login"
elif agent_signs; then
  ok "Chave já está destravada no agente"
else
  info "Adicionando a chave ao agente (digite a senha da chave):"
  ssh-add "$KEY_PATH" || die "ssh-add falhou; a chave não foi adicionada."
  agent_signs || die "O agente não conseguiu assinar com a chave."
  ok "Chave guardada no agente"
  NO_KEYRING=1
fi

# ---- 3. Git: assinatura SSH ----
git config --global gpg.format ssh
git config --global user.signingkey "$PUB_PATH"
git config --global commit.gpgsign true
ok "Git configurado para assinar commits com a chave SSH"

# Sem isso o git assina, mas não consegue validar (git log --show-signature)
email="$(git config --global user.email || true)"
if [[ -n "$email" ]]; then
  signer="$email $(awk '{print $1, $2}' "$PUB_PATH")"
  touch "$ALLOWED_SIGNERS"
  grep -qxF "$signer" "$ALLOWED_SIGNERS" || echo "$signer" >>"$ALLOWED_SIGNERS"
  git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
  ok "Validação local configurada ($ALLOWED_SIGNERS)"
else
  echo "[!!] user.email não está definido no git global; validação local não configurada."
  echo "     Defina com: git config --global user.email voce@exemplo.com e rode de novo."
fi

# ---- 4. GitHub ----
echo
if [[ -n "${WAYLAND_DISPLAY:-}" ]] && has_command wl-copy; then
  wl-copy <"$PUB_PATH"
  echo "Chave pública copiada para a área de transferência."
elif [[ -n "${DISPLAY:-}" ]] && has_command xclip; then
  xclip -selection clipboard <"$PUB_PATH"
  echo "Chave pública copiada para a área de transferência."
else
  echo "Chave pública:"
  cat "$PUB_PATH"
fi
echo "GitHub > Settings > SSH and GPG keys > New SSH key > Key type: Signing Key"
echo "  https://github.com/settings/ssh/new"
echo "O e-mail do git (${email:-não definido}) precisa estar verificado na conta."

if [[ -n "${NEW_AGENT:-}" ]]; then
  echo
  echo "O agente novo vale para sessões abertas a partir do próximo login. Em shells que"
  echo "não herdam o ambiente do systemd (TTY, SSH), adicione ao rc do shell:"
  echo "  export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/$AGENT_SOCK_NAME\""
fi
if [[ -n "${NO_KEYRING:-}" ]]; then
  echo
  echo "[!!] Sem chaveiro: este agente guarda a chave só na memória e ela precisa de"
  echo "     'ssh-add' após cada boot. Instale gnome-keyring, gcr e libsecret (secret-tool)"
  echo "     e rode de novo para a chave destravar sozinha no login."
fi

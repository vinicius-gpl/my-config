# 🔐 Assinatura de Commits com Chave SSH (Linux & Windows)

Automação completa para configurar assinatura de commits Git com chave SSH sem pedir passphrase a cada commit, integrando diretamente com os agentes nativos de credenciais do sistema operacional.

---

## 📌 Como Funciona

Assinar commits com uma chave SSH protegida por senha faz o Git pedir a senha **a cada commit**, a menos que ela esteja armazenada em um agente SSH ativo:

```text
git commit  ──>  ssh-keygen -Y sign  ──>  ssh-agent (chave destravada na memória ou chaveiro)
```

Este diretório contém a automação para os dois ambientes:
* **Linux (Arch, Ubuntu, Fedora, Debian):** [`enable-ssh-signing.sh`](./enable-ssh-signing.sh)
* **Windows (PowerShell 7+ / 5.1):** [`enable-ssh-signing.ps1`](./enable-ssh-signing.ps1)

---

## 🐧 Uso no Linux

O script configura permissões seguras (`600`), integra com o chaveiro do sistema (`secret-tool` / `gnome-keyring` / `gcr-ssh-agent`) ou `systemd --user ssh-agent`, e ajusta as variáveis do Git global.

```bash
# Executar com a chave padrão (~/.ssh/id_ed25519)
./enable-ssh-signing.sh

# Ou apontar para outra chave específica
./enable-ssh-signing.sh ~/.ssh/minha_chave
```

### Se precisar reiniciar o serviço no Linux:
```bash
systemctl --user restart gcr-ssh-agent.service
```

---

## 🪟 Uso no Windows

No Windows, o serviço do OpenSSH Authentication Agent costuma vir desativado por padrão. O script ativa o serviço, carrega a chave e configura o Git global para usar o binário nativo `ssh-keygen.exe`:

```powershell
# Executar no PowerShell (como Administrador ou com confirmação de UAC)
.\enable-ssh-signing.ps1

# Ou especificando o caminho da chave
.\enable-ssh-signing.ps1 -KeyPath "$HOME\.ssh\minha_chave"
```

---

## 🌐 Cadastrar a Chave no GitHub

Depois de rodar o script (a chave pública será copiada automaticamente para o clipboard ou exibida no terminal):

1. Vá em [GitHub → Settings → SSH and GPG keys → New SSH key](https://github.com/settings/ssh/new).
2. Cole a chave pública.
3. **MUITO IMPORTANTE:** Selecione **Key type:** `Signing Key` (se cadastrar como *Authentication Key*, o commit não será verificado!).
4. Garanta que o seu `git config user.email` seja um e-mail verificado na sua conta do GitHub.

---

## ✅ Como Validar se Funcionou

```bash
# 1. Verificar se a chave está no agente
ssh-add -l

# 2. Criar um commit de teste assinado
git commit --allow-empty -m "teste de assinatura"

# 3. Conferir a assinatura do commit
git log --show-signature -1
# Deve exibir: Good "git" signature for seu-email@dominio.com
```

---

## 🧹 Como Desfazer

```bash
git config --global --unset commit.gpgsign
git config --global --unset gpg.format
git config --global --unset user.signingkey
git config --global --unset gpg.ssh.allowedSignersFile
git config --global --unset gpg.ssh.program   # se no Windows
```

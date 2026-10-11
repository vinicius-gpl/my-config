# 💻 Ambientes Desktop & Dotfiles

Este diretório centraliza todas as configurações, scripts de personalização, gerenciadores de pacotes e automações para estações de trabalho pessoais (**Arch Linux** e **Windows 11**), além dos **Dotfiles** compartilhados.

---

## 📂 Estrutura de Diretórios

```text
configuration/desktop/
├── arch/                     # 🐧 Provisionamento completo para Arch Linux (Hyprland)
│   ├── ansible/              # Playbook local Ansible (pacman, yay, pacotes, symlinks)
│   └── README.md             # Instruções de execução local no Arch
│
├── windows/                  # 🪟 Configurações e utilitários para Windows 11
│   ├── .config/              # Dotfiles do Windows (WezTerm, PowerShell, Zellij, Alacritty)
│   ├── alacritty-conpty/     # Script para compilar/instalar ConPTY atualizado no Windows
│   ├── git-ssh-signing/      # Script PowerShell para assinar commits com SSH Agent
│   ├── keyboard-us-intl/     # Trava de layout do teclado US Internacional no Windows 11
│   ├── scripts-install-apps/ # Instalação de apps em massa via WinGet
│   └── windows-11-generate-iso/ # Script oscdimg para gerar ISO limpa do Windows 11
│
├── dotfiles/                 # ⚙️ Dotfiles universais (Shell, Terminais, Editores, WM)
│   ├── .dotfiles/            # Pastas de configuração (.config) prontas para symlink:
│   │   ├── fish/             # Fish shell
│   │   ├── hypr/             # Hyprland Wayland compositor + hyprlock/hypridle
│   │   ├── kitty/            # Kitty terminal
│   │   ├── lazygit/          # TUI do Git
│   │   ├── mise/             # Gerenciador de runtimes e ferramentas
│   │   ├── nvim/             # Neovim (configs completas)
│   │   ├── ohmyposh/         # Prompt customizado
│   │   ├── wezterm/          # WezTerm terminal
│   │   ├── zed/              # Zed editor
│   │   ├── zellij/           # Multiplexador de terminal
│   │   ├── fastfetch/        # Informações de sistema
│   │   ├── .bashrc           # Configuração de Bash
│   │   └── starship.toml     # Prompt Starship
│   ├── theme/                # Tema do GRUB (Frieren Dark Window Left) + install.sh
│   └── .docker/              # Docker compose locais de suporte (DNS, Manga)
│
└── git-ssh-signing/          # 🔐 Automação de assinatura de commits Git (Multi-OS)
    ├── enable-ssh-signing.sh # Script para Linux (PAM/Secret-tool/GCR/systemd)
    ├── enable-ssh-signing.ps1# Script para Windows (OpenSSH Authentication Agent)
    └── README.md             # Guia de configuração e cadastro no GitHub
```

---

## 🐧 1. Arch Linux (Hyprland + Wayland)

O provisionamento do Arch é feito diretamente na própria máquina (conexão `local`), criando symlinks que apontam para este repositório:

```bash
# Instalar o Ansible
sudo pacman -S --needed ansible

# Entrar no diretório e executar
cd configuration/desktop/arch/ansible
sudo -v && ansible-playbook -i inventory.ini setup_desktop.yml -K
```

*Consulte [`configuration/desktop/arch/README.md`](./arch/README.md) para detalhes de tags (`pkgs`, `dotfiles`, `yay`, `shell`).*

---

## 🪟 2. Windows 11

No Windows, cada pasta resolve um ponto de fricção específico do sistema operacional:

* **Instalar Programas:** Execute `winget import configuration/desktop/windows/scripts-install-apps/install.winget` para instalar todo o ecossistema de ferramentas de desenvolvimento.
* **Travar Teclado US-Intl:** O Windows 11 frequentemente adiciona layouts indesejados (ex: ABNT). O script [`keyboard-us-intl/lock-us-intl.ps1`](./windows/keyboard-us-intl/README.md) remove os layouts secundários e fixa o US-Internacional.
* **Corrigir Terminal (ConPTY):** O script [`alacritty-conpty/install-conpty.ps1`](./windows/alacritty-conpty/README.md) injeta uma versão moderna da OpenConsole no Alacritty para suportar emojis, cores 24-bit e rendering limpo.
* **Perfis e Dotfiles:** Os arquivos em `.config` fornecem o perfil do PowerShell (`Microsoft.PowerShell_profile.ps1`), WezTerm (`.wezterm.lua`), Zellij e Alacritty.

---

## 🔐 3. Assinatura de Commits com Chave SSH

Para evitar que o Git solicite a senha da sua chave SSH privada a cada commit:

* **No Linux:**
  ```bash
  cd configuration/desktop/git-ssh-signing
  ./enable-ssh-signing.sh
  ```
* **No Windows:**
  ```powershell
  cd configuration/desktop/git-ssh-signing
  .\enable-ssh-signing.ps1
  ```

*Consulte [`configuration/desktop/git-ssh-signing/README.md`](./git-ssh-signing/README.md) para o passo a passo completo de cadastro no GitHub.*

# 💻 Ambientes Desktop & Workstations

Estrutura unificada e modular para estações de trabalho pessoais (**Linux / Arch Linux** e **Windows 11**), com separação estrita de responsabilidades entre **Ansible**, **Dotfiles**, **Scripts**, **Temas** e **Docker**.

---

## 🏗️ Estrutura Organizada

```text
configuration/desktop/
│
├── ansible/                  # 🤖 Automação e Provisionamento (Arch Linux / Hyprland)
│   ├── inventory.ini         # Inventário local (localhost)
│   ├── setup_desktop.yml     # Playbook que instala pacotes (pacman/yay) e linka dotfiles
│   └── README.md             # Guia de execução passo a passo
│
├── dotfiles/                 # ⚙️ Arquivos de Configuração Puros (Sem scripts ou binários)
│   ├── linux/                # Configurações do Linux (para ~/.config e ~/)
│   │   ├── fastfetch/        # Informações de sistema
│   │   ├── fish/             # Shell Fish
│   │   ├── hypr/             # Hyprland compositor + hyprlock/hypridle
│   │   ├── kitty/            # Terminal Kitty
│   │   ├── lazygit/          # TUI do Git
│   │   ├── mise/             # Gerenciador de runtimes e polyglot tool versioning
│   │   ├── nvim/             # Editor Neovim
│   │   ├── ohmyposh/         # Temas de prompt Oh My Posh
│   │   ├── wezterm/          # Terminal WezTerm
│   │   ├── zed/              # Editor Zed
│   │   ├── zellij/           # Multiplexador de terminal
│   │   ├── .bashrc           # Configuração base Bash
│   │   └── starship.toml     # Prompt Starship
│   └── windows/              # Configurações do Windows (AppData e Perfis)
│       ├── alacritty/        # alacritty.toml e tema Catppuccin Mocha
│       ├── powershell/       # Microsoft.PowerShell_profile.ps1
│       ├── wezterm/          # .wezterm.lua
│       ├── zellij/           # config.kdl
│       ├── git-hooks/        # Hooks globais do Git (prepare-commit-msg)
│       └── posh/             # posh.json
│
├── scripts/                  # 📜 Scripts Utilitários Standalone (Execução direta)
│   ├── git-ssh-signing/      # Automação de assinatura de commits via SSH Agent (Multi-OS)
│   │   ├── enable-ssh-signing.sh   # Script Bash (Linux)
│   │   ├── enable-ssh-signing.ps1  # Script PowerShell (Windows)
│   │   └── README.md               # Instruções e integração com GitHub
│   └── windows/              # Utilitários de automação do Windows
│       ├── alacritty-conpty/ # Injeção de ConPTY atualizado no Alacritty
│       ├── keyboard-us-intl/ # Trava de layout do teclado US Internacional no Windows 11
│       ├── install-apps/     # Instalação de ferramentas em lote via WinGet
│       └── generate-iso/     # Criação de imagem ISO limpa do Windows 11 via oscdimg
│
├── themes/                   # 🎨 Temas Visuais e Bootloader
│   └── grub/                 # Tema Frieren Dark para o GRUB bootloader
│       ├── frieren-window-left-dark/
│       └── install.sh        # Script instalador do tema
│
└── docker/                   # 🐳 Stacks e Configurações Docker Locais de Desktop
    ├── dns/                  # Configurações locais AdGuard, Pi-hole e Unbound
    └── mangas/               # Configurações Komf e Manga-dlp
```

---

## 🚀 Como Usar Cada Módulo

### 1. Provisionar Desktop Arch Linux (Hyprland)
O provisionamento é 100% automatizado via Ansible local:

```bash
# 1. Instalar o Ansible
sudo pacman -S --needed ansible

# 2. Executar o playbook do desktop
cd configuration/desktop/ansible
sudo -v && ansible-playbook -i inventory.ini setup_desktop.yml -K
```
*Ele instala os pacotes oficiais, pacotes do AUR via yay, define o shell Fish e cria symlinks automáticos apontando de `~/.config` para `configuration/desktop/dotfiles/linux`.*

---

### 2. Configurar Assinatura de Commits com Chave SSH
Elimina o pedido constante de senha da chave SSH a cada commit:

* **No Linux:**
  ```bash
  cd configuration/desktop/scripts/git-ssh-signing
  ./enable-ssh-signing.sh
  ```
* **No Windows:**
  ```powershell
  cd configuration/desktop/scripts/git-ssh-signing
  .\enable-ssh-signing.ps1
  ```

---

### 3. Utilitários Windows 11
Dentro de `configuration/desktop/scripts/windows/`:
* **Instalar apps:** `winget import scripts/windows/install-apps/install.winget`
* **Fixar teclado US-Intl:** Execute `scripts/windows/keyboard-us-intl/lock-us-intl.ps1`
* **Corrigir ConPTY no Alacritty:** Execute `scripts/windows/alacritty-conpty/install-conpty.ps1`
* **Aplicar Dotfiles do Windows:** Execute `scripts/windows/sync-dotfiles.ps1`

---

### 4. Mapeamento de Destino dos Dotfiles
Consulte o guia completo com a tabela de destinos para cada arquivo e pasta em:
👉 **[`configuration/desktop/dotfiles/README.md`](./dotfiles/README.md)**

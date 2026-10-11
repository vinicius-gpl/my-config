# ⚙️ Dotfiles — Guia de Mapeamento e Destinos

Este diretório contém todas as configurações puras de terminal, editores, prompts, shell e gerenciadores de janelas.

Abaixo está o mapeamento exato de **onde cada pasta e arquivo deve ficar** no sistema operacional (Linux e Windows), além de comandos prontos para aplicar.

---

## 🐧 1. Mapeamento Linux (Arch, Fedora, Debian, Ubuntu)

No Linux, a convenção padrão segue o **XDG Base Directory Specification** (`~/.config/` e `~/`).

| Origem no Repositório (`dotfiles/linux/`) | Destino no Sistema | Aplicação / Ferramenta | Descrição |
| :--- | :--- | :--- | :--- |
| **`fastfetch/`** | `~/.config/fastfetch/` | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Informações do sistema e hardware no terminal |
| **`fish/`** | `~/.config/fish/` | [Fish Shell](https://fishshell.com/) | Configuração principal do shell Fish (funções, aliases e config.fish) |
| **`hypr/`** | `~/.config/hypr/` | [Hyprland](https://hyprland.org/) | Configuração do compositor Wayland, atalhos, `hyprlock.conf` e `hypridle.conf` |
| **`kitty/`** | `~/.config/kitty/` | [Kitty](https://sw.kovidgoyal.net/kitty/) | Emulador de terminal acelerado por GPU (fontes, cores, atalhos) |
| **`lazygit/`** | `~/.config/lazygit/` | [Lazygit](https://github.com/jesseduffield/lazygit) | Interface TUI de gerenciamento Git |
| **`mise/`** | `~/.config/mise/` | [Mise-en-place](https://mise.jdx.dev/) | Gerenciador polyglot de ferramentas e versões de linguagens (Node, Go, Python) |
| **`nvim/`** | `~/.config/nvim/` | [Neovim](https://neovim.io/) | IDE/Editor de texto modal completo em Lua (plugins, LSP, temas) |
| **`ohmyposh/`** | `~/.config/ohmyposh/` | [Oh My Posh](https://ohmyposh.dev/) | Temas e renderizador de prompt multiplataforma |
| **`wezterm/`** | `~/.config/wezterm/` | [WezTerm](https://wezfurlong.org/wezterm/) | Terminal multiplataforma configurável em Lua |
| **`zed/`** | `~/.config/zed/` | [Zed Editor](https://zed.dev/) | Editor de código nativo de alta performance |
| **`zellij/`** | `~/.config/zellij/` | [Zellij](https://zellij.dev/) | Multiplexador de terminal moderno (layouts, plugins, abas e painéis) |
| **`.bashrc`** | `~/.bashrc` | GNU Bash | Configuração de fallback para sessões Bash |
| **`starship.toml`** | `~/.config/starship.toml` | [Starship](https://starship.rs/) | Configuração de prompt universal em Rust |

### 🚀 Como Aplicar no Linux

#### Opção A: Automático via Ansible (Recomendado)
O playbook do repositório já cria todos os symlinks automaticamente, fazendo backup de configs existentes:
```bash
cd configuration/desktop/ansible
ansible-playbook -i inventory.ini setup_desktop.yml --tags dotfiles
```

#### Opção B: Manualmente via Symlinks (Bash)
```bash
DOTFILES_DIR="$(pwd)/configuration/desktop/dotfiles/linux"

# Criar pasta ~/.config se não existir
mkdir -p ~/.config

# Linkar as pastas no ~/.config
for item in fastfetch fish hypr kitty lazygit mise nvim ohmyposh wezterm zed zellij; do
    ln -sfn "$DOTFILES_DIR/$item" "$HOME/.config/$item"
done

# Linkar arquivos individuais
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
```

---

## 🪟 2. Mapeamento Windows 11

No Windows, as configurações ficam distribuídas entre `%APPDATA%`, `%USERPROFILE%` e a pasta de `Documents\PowerShell`.

| Origem no Repositório (`dotfiles/windows/`) | Destino no Sistema | Caminho Completo Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| **`alacritty/`** | `%APPDATA%\alacritty\` | `C:\Users\<user>\AppData\Roaming\alacritty\` | `alacritty.toml` e tema `catppuccin-mocha.toml` |
| **`powershell/`** | `$PROFILE` | `C:\Users\<user>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | Perfil global do PowerShell (PSReadLine, Mise, Oh My Posh) |
| **`wezterm/`** | `%USERPROFILE%\.wezterm.lua` | `C:\Users\<user>\.wezterm.lua` | Configuração Lua do WezTerm para Windows |
| **`zellij/`** | `%APPDATA%\zellij\config\` | `C:\Users\<user>\AppData\Roaming\zellij\config\config.kdl` | Layouts e atalhos do multiplexador Zellij no Windows |
| **`posh/`** | `%USERPROFILE%\posh.json` | `C:\Users\<user>\posh.json` | Tema customizado do prompt Oh My Posh usado no PowerShell |
| **`git-hooks/`** | `%USERPROFILE%\.config\.git-hooks\` | `C:\Users\<user>\.config\.git-hooks\prepare-commit-msg` | Hook global para padronização de mensagens de commit |

### 🚀 Como Aplicar no Windows (PowerShell)

Abra o PowerShell e execute o bloco abaixo para criar links simbólicos (ou copiar) para os locais corretos:

```powershell
$REPO_DOTFILES = "$PSScriptRoot\configuration\desktop\dotfiles\windows"
# Se rodando direto no terminal, ajuste para o caminho absoluto do seu repo:
if (-not (Test-Path $REPO_DOTFILES)) { $REPO_DOTFILES = "C:\Users\$env:USERNAME\Desktop\my-config\configuration\desktop\dotfiles\windows" }

# 1. Alacritty
New-Item -ItemType Directory -Force -Path "$env:APPDATA\alacritty" | Out-Null
Copy-Item "$REPO_DOTFILES\alacritty\*" "$env:APPDATA\alacritty\" -Force

# 2. PowerShell Profile
$psDir = Split-Path $PROFILE
New-Item -ItemType Directory -Force -Path $psDir | Out-Null
Copy-Item "$REPO_DOTFILES\powershell\Microsoft.PowerShell_profile.ps1" "$PROFILE" -Force

# 3. WezTerm
Copy-Item "$REPO_DOTFILES\wezterm\.wezterm.lua" "$HOME\.wezterm.lua" -Force

# 4. Zellij
New-Item -ItemType Directory -Force -Path "$env:APPDATA\zellij\config" | Out-Null
Copy-Item "$REPO_DOTFILES\zellij\config.kdl" "$env:APPDATA\zellij\config\config.kdl" -Force

# 5. Oh My Posh Theme
Copy-Item "$REPO_DOTFILES\posh\posh.json" "$HOME\posh.json" -Force

# 6. Git Hooks Globais
New-Item -ItemType Directory -Force -Path "$HOME\.config\.git-hooks" | Out-Null
Copy-Item "$REPO_DOTFILES\git-hooks\prepare-commit-msg" "$HOME\.config\.git-hooks\" -Force
git config --global core.hooksPath "$HOME\.config\.git-hooks"

Write-Host "✅ Todos os dotfiles do Windows foram aplicados com sucesso!" -ForegroundColor Green
```

---

## 💡 Dica de Manutenção

* **No Linux:** Como as configurações entram por **symlink** (`ln -s`), qualquer alteração feita nos arquivos do repositório é refletida imediatamente no sistema, sem precisar reaplicar nada.
* **No Windows:** Você pode usar `New-Item -ItemType SymbolicLink` (requer Modo Desenvolvedor ativo no Windows 11) para ter o mesmo comportamento de sincronização em tempo real dos symlinks do Linux.

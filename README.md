# My Config & Infrastructure

Repositório central de configurações, automações de infraestrutura e dotfiles.

---

## 🏗️ Estrutura do Repositório

```text
configuration/
├── servers/             # 🖥️ Inventários e variáveis por SERVIDOR (independente de distro)
│   ├── acerola/         # Servidor Relay público (Caddy, WireGuard, Portainer, Beszel)
│   ├── homelab/         # Servidor Homelab / Local (Coolify, Supabase, Beszel, Cockpit)
│   └── siaap/           # Servidor SIAAP (Debian / Nginx)
│
├── apps/                # 📦 Catálogo de APPS (Docker Compose + configs prontas)
│   ├── wireguard/       # wg-easy com suporte a host network e QR Code
│   ├── caddy/           # Proxy reverso principal com TLS automático
│   ├── portainer/       # Gerenciamento de containers
│   ├── coolify/         # PaaS self-hosted (alternativa ao Heroku/Vercel)
│   ├── supabase/        # Backend self-hosted (Postgres, Kong, Studio, Storage)
│   ├── beszel/          # Monitoramento de hardware e containers (Hub e Agent)
│   ├── cockpit/         # Painel administrativo do host
│   └── ...              # authelia, netdata, transmission, dns, traefik
│
├── ansible/             # 🤖 Automação agnóstica de distro
│   ├── deploy.yml       # Playbook unificado multi-servidor / multi-app
│   └── hosts.ini        # Inventário ativo gerado
│
└── desktop/             # 💻 Ambientes Desktop e Dotfiles
    ├── arch/            # Provisionamento Ansible do desktop Arch (pacman/yay/KDE)
    ├── windows/         # Scripts e ajustes do Windows (ConPTY, teclado, SSH)
    ├── dotfiles/        # Configurações de shell e terminais (.config, fish, zellij, kitty)
    └── git-ssh-signing/ # Automação de assinatura de commits via chave SSH
```

---

## 🚀 Como fazer Deploy via GitHub Actions

O repositório utiliza **um único workflow unificado** ([`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)).

Para executar um deploy:
1. Vá na aba **Actions** > **Server Deploy** > **Run workflow**.
2. Selecione o **servidor alvo**: `acerola`, `homelab` ou `siaap`.
3. Selecione a **etapa / app**: `all`, `base`, `wireguard`, `caddy`, `portainer`, `coolify`, `supabase`, `beszel`, `cockpit`.
4. Clique em **Run workflow**.

### Autenticação no GitHub (Environments)
Você pode cadastrar as credenciais em **Settings > Environments** criando um ambiente para cada servidor (`acerola`, `homelab`, `siaap`):
- `SSH_PRIVATE_KEY`
- `ANSIBLE_HOSTS_INI`
- `ANSIBLE_BECOME_PASSWORD`

*(Se não usar Environments, o workflow também aceita secrets com prefixo do servidor, ex: `ACEROLA_ANSIBLE_HOSTS_INI`).*

---

## 🛠️ Como rodar o Ansible localmente

Para rodar qualquer deploy diretamente da sua máquina:

```bash
# Exemplo 1: Subir tudo no servidor acerola
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml

# Exemplo 2: Subir apenas o WireGuard e o Caddy no servidor acerola
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml --tags "wireguard,caddy"

# Exemplo 3: Subir Coolify e Supabase no homelab
ansible-playbook -i configuration/servers/homelab/inventory.ini configuration/ansible/deploy.yml --tags "coolify,supabase"
```

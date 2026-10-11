# My Config & Infrastructure

Repositório central de configurações, automações de infraestrutura e dotfiles.

---

## 🏗️ Estrutura do Repositório

```text
configuration/
├── servers/             # 🖥️ Inventários e variáveis por SERVIDOR (independente de distro)
│   ├── acerola/         # Servidor Acerola
│   └── oracle/          # Servidor Oracle
│
├── apps/                # 📦 Catálogo de APPS (Docker Compose + configs prontas)
│   ├── wireguard/       # wg-easy com suporte a host network e QR Code
│   ├── netbird/         # VPN Mesh com WireGuard, ACLs, Grupos e GitHub SSO
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
    ├── arch/            # Provisionamento Ansible do desktop Arch (pacman/yay/Hyprland)
    ├── windows/         # Scripts e ajustes do Windows (ConPTY, teclado, SSH)
    ├── dotfiles/        # Configurações de shell e terminais (.config, fish, zellij, kitty)
    └── git-ssh-signing/ # Automação de assinatura de commits via chave SSH (Linux & Windows)
```

---

## 🚀 Como fazer Deploy via GitHub Actions

O repositório conta com dois workflows dedicados:
* **[Ansible Deploy](.github/workflows/deploy.yml):** Para provisionamento e subida de containers.
* **[Ansible Clean](.github/workflows/clean.yml):** Para parar e remover serviços específicos em servidores alvo com total controle.

### Deploy de Serviços:
1. Vá na aba **Actions** > **Ansible Deploy** > **Run workflow**.
2. Selecione o **servidor alvo**: `acerola` ou `oracle`.
3. Selecione a **etapa / app**: `all`, `base`, `wireguard`, `netbird`, `netbird-client`, `caddy`, `portainer`, `portainer-agent`, `coolify`, `supabase`, `beszel`, `beszel-hub`, `cockpit`.
4. Clique em **Run workflow**.

### Limpeza / Remoção Controlada de Serviços:
1. Vá na aba **Actions** > **Ansible Clean** > **Run workflow**.
2. Selecione o **servidor alvo**: `acerola` ou `oracle`.
3. Selecione o **serviço para deitar**: `dashboards` (Beszel Hub + Portainer Server), `beszel-hub`, `portainer`, `portainer-agent`, `beszel-agent`, `wireguard`, `netbird`, `netbird-client`, `caddy`, `cockpit` ou `prune`.
4. Marque se deseja apagar os volumes de dados persistentes (`remove_volumes`).
5. Clique em **Run workflow**.

### Autenticação no GitHub (Environments)
Você pode cadastrar as credenciais em **Settings > Environments** criando um ambiente para cada servidor (`acerola` e `oracle`):
- `SSH_PRIVATE_KEY`
- `ANSIBLE_HOSTS_INI` (veja modelos em [`configuration/servers/HOSTS_FORMATS.md`](configuration/servers/HOSTS_FORMATS.md))
- `SSH_PASSPHRASE` (opcional)
- `ANSIBLE_BECOME_PASSWORD` (opcional)

*(Se não usar Environments, o workflow também aceita secrets com prefixo do servidor, ex: `ACEROLA_ANSIBLE_HOSTS_INI` ou `ORACLE_ANSIBLE_HOSTS_INI`).*

Consulte o [**Guia de Formatos de Inventário (`HOSTS_FORMATS.md`)**](configuration/servers/HOSTS_FORMATS.md) para todos os modelos prontos de `hosts.ini`.

---

## 🛠️ Como rodar o Ansible localmente

Para rodar qualquer deploy diretamente da sua máquina:

```bash
# Exemplo 1: Subir tudo no servidor acerola
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml

# Exemplo 2: Subir apenas o WireGuard e o Caddy no servidor acerola
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml --tags "wireguard,caddy"

# Exemplo 3: Subir Coolify e Supabase no servidor oracle
ansible-playbook -i configuration/servers/oracle/inventory.ini configuration/ansible/deploy.yml --tags "coolify,supabase"
```

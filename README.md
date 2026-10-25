# My Config & Infrastructure

Repositório central de configurações, automações de infraestrutura e dotfiles.

---

## 🏗️ Estrutura do Repositório

```text
configuration/
├── servers/             # 🖥️ Inventários e variáveis por SERVIDOR (independente de distro)
│   ├── REDE.md          # Arquitetura da rede: DNS, VPN, acesso e fluxos
│   ├── acerola/         # Servidor Acerola
│   ├── oracle/          # Servidor Oracle (borda pública, NetBird, vars.yml)
│   └── pluto/           # Desktop PLUTO (serviços locais publicados via Oracle)
│
├── apps/                # 📦 Catálogo de APPS (Docker Compose + configs prontas)
│   ├── wireguard/       # wg-easy com suporte a host network e QR Code
│   ├── netbird/         # VPN Mesh com WireGuard, ACLs, Grupos e GitHub SSO
│   ├── caddy/           # Proxy reverso principal com TLS automático
│   ├── portainer/       # Gerenciamento de containers
│   ├── coolify/         # PaaS self-hosted (alternativa ao Heroku/Vercel)
│   ├── supabase/        # Backend self-hosted (Postgres, Kong, Studio, Storage)
│   ├── beszel/          # Monitoramento de hardware e containers (Hub e Agent)
│   ├── komodo/          # Painel de deploy (Core na Oracle) e agente Periphery nos servidores
│   ├── cockpit/         # Painel administrativo do host
│   ├── element-call/    # Videoconferência Matrix (MatrixRTC + LiveKit)
│   ├── element-web/     # Chat e mensagens Matrix (Slack/Discord open source)
│   └── ...              # authelia, netdata, transmission, dns, traefik
│
├── ansible/             # 🤖 Automação agnóstica de distro
│   ├── deploy.yml       # Playbook unificado multi-servidor / multi-app
│   └── hosts.ini        # Inventário ativo gerado
│
└── desktop/             # 💻 Ambientes Desktop e Workstations
    ├── ansible/         # Provisionamento Ansible local (Arch Linux / Hyprland)
    ├── dotfiles/        # Configurações puras de ambiente (linux e windows)
    ├── scripts/         # Scripts utilitários standalone (SSH signing, Windows tweaks)
    ├── themes/          # Temas visuais (GRUB bootloader)
    └── docker/          # Stacks e configs Docker locais de desktop
```

---

## 🌐 Rede e acesso

Como os serviços são publicados, quais são privados (só VPN) e por onde o tráfego passa:
[**`configuration/servers/REDE.md`**](configuration/servers/REDE.md).

---

## 🚀 Como fazer Deploy via GitHub Actions

O repositório conta com dois workflows dedicados:
* **[Ansible Deploy](.github/workflows/deploy.yml):** Para provisionamento e subida de containers.
* **[Ansible Clean](.github/workflows/clean.yml):** Para parar e remover serviços específicos em servidores alvo com total controle.

### Deploy de Serviços:
1. Vá na aba **Actions** > **Ansible Deploy** > **Run workflow**.
2. Selecione o **servidor alvo**: `acerola` ou `oracle`.
3. Selecione a **etapa / app**: `all`, `base`, `wireguard`, `netbird`, `netbird-client`, `caddy`, `portainer`, `portainer-agent`, `coolify`, `supabase`, `beszel`, `beszel-hub`, `netbird-proxy`, `cockpit`, `sure`, `element-call`, `element-web`, `monitoring`, `komodo`, `komodo-periphery` ([detalhes](configuration/apps/komodo/README.md)).
4. Clique em **Run workflow**.

Se existir `configuration/servers/<servidor>/vars.yml`, o workflow carrega esse arquivo como variáveis
do deploy (configuração não secreta do servidor, versionada no repositório).

### Limpeza / Remoção Controlada de Serviços:
1. Vá na aba **Actions** > **Ansible Clean** > **Run workflow**.
2. Selecione o **servidor alvo**: `acerola` ou `oracle`.
3. Selecione o **serviço para deitar**: `dashboards` (Beszel Hub + Portainer Server), `beszel-hub`, `portainer`, `portainer-agent`, `beszel-agent`, `wireguard`, `netbird`, `netbird-client`, `netbird-proxy`, `caddy`, `cockpit`, `sure`, `coolify`, `supabase`, `monitoring`, `komodo`, `komodo-periphery` ou `prune`.
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

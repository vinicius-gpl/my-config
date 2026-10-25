# Komodo: painel de deploy dos servidores

[Komodo](https://komo.do) v2: um painel (Core) gerencia o Docker de todos os servidores por um agente
(Periphery) em cada um. Os stacks vêm do git e cada um escolhe o servidor onde roda.

Trazido do repositório `grupo-azuos/server`. Lá o painel escuta no IP do NetBird; aqui ele segue o
padrão da Oracle: sem porta publicada, entregue pelo Caddy em `komodo.<domain>` com `vpn_only`.

```text
oracle
  Caddy  komodo.vinicius-gpl.com   painel e agentes só pela VPN; /listener/* público (webhooks)
    └─ Komodo Core + Mongo (/opt/komodo, rede proxy)
        ▲
        │ WebSocket autenticado por par de chaves (o agente é quem conecta)
        │
oracle  → ws://komodo-core:9120 (mesmo Docker)
acerola → wss://komodo.vinicius-gpl.com pela VPN (Ansible)
pluto   → wss://komodo.vinicius-gpl.com pela VPN (docker compose desta pasta)
  Komodo Periphery   sem porta publicada; age no Docker local, stacks e repos em /etc/komodo
```

## Arquivos

| Arquivo | Vai para | Onde roda |
|---|---|---|
| `compose.core.yml` | `/opt/komodo` | oracle |
| `config/secrets.env.j2` | `/opt/komodo/secrets.env` | gerado uma vez, nunca sobrescrito |
| `config/komodo.caddy` | `/opt/caddy/conf.d/` | oracle (também em `caddy_sites` do `vars.yml`) |
| `compose.periphery.yml` | `/opt/komodo-periphery` | todo servidor com agente |
| `config/periphery.env.j2` | `/opt/komodo-periphery/periphery.env` | endereço do Core, nome e onboarding key |
| `periphery.env.example` | `periphery.env` (não versionado) | agente fora do Ansible (PLUTO) |

As versões ficam no `vars:` do `deploy.yml` (`komodo_version`, `komodo_mongo_version`), assim como
`komodo_core_address` (padrão `wss://komodo.vinicius-gpl.com`; a Oracle sobrescreve no `vars.yml`).

## Variáveis do `hosts.ini`

| Variável | Onde | Para quê |
|---|---|---|
| `komodo_admin_password` | oracle | senha do `admin` (só vale na primeira subida) |
| `komodo_onboarding_key` | todo servidor com agente | registra o agente no painel (criada no painel) |
| `komodo_server_name` | opcional | nome no painel; padrão é o hostname (a Oracle usa `oracle`) |

Para a etapa `all` também subir o Komodo, use `komodo_enabled=true` / `komodo_periphery_enabled=true`.

## Deploy

Pré-requisitos: Caddy e NetBird já rodando na Oracle; os outros servidores já são peers do NetBird
com a rota `oracle-public-ip` (é o que faz o `vpn_only` deixar o agente passar). Registro A `komodo`
na Cloudflare, só DNS, com o IP da Oracle.

**1. Painel**: Actions → **Ansible Deploy** → servidor `oracle`, etapa `komodo`. Ou localmente:

```bash
ansible-playbook -i configuration/servers/oracle/hosts.ini configuration/ansible/deploy.yml \
  -e @configuration/servers/oracle/vars.yml --tags komodo
```

Conferir (na VPN): `https://komodo.vinicius-gpl.com`, login `admin`.

**2. Onboarding key (manual)**: no painel, **Settings → Onboarding**, crie uma chave reutilizável e
coloque em `komodo_onboarding_key` no `hosts.ini` (secret `ANSIBLE_HOSTS_INI`) de cada servidor.

**3. Agentes**: etapa `komodo-periphery` em `oracle` e `acerola`. No PLUTO:

```bash
cd configuration/apps/komodo
cp periphery.env.example periphery.env    # preencha a onboarding key
sudo mkdir -p /etc/komodo
docker compose -f compose.periphery.yml up -d
```

Cada agente aparece em **Servers**. Depois do primeiro registro a onboarding key não é mais necessária.

## Replicar o Komodo (o mesmo setup em outro lugar)

- **Outro servidor como painel**: rode a etapa `komodo` nele (com `komodo_admin_password` e o
  `komodo.caddy` em `caddy_sites`) e aponte os agentes para ele com `komodo_core_address`.
- **Copiar os dados de um Core para outro** (stacks, servidores, usuários): o Komodo grava backups
  datados em `/etc/komodo/backups`; restaure um deles no Mongo do Core novo
  ([docs](https://komo.do/docs/setup/backup)). Ou exporte os recursos como TOML no painel
  (**Syncs**) e importe no outro.
- **Trocar de Core** muda o par de chaves: apague o volume `komodo-periphery-keys` dos agentes e
  refaça o onboarding (ver Cuidados).

## Remover

Actions → **Ansible Clean** → `komodo` ou `komodo-periphery` (*remove_volumes* apaga banco/chaves).
O `/etc/komodo` dos servidores fica: lá estão os stacks publicados e os backups do banco.

## Cuidados

- **O agente controla o Docker inteiro do servidor** (equivale a root). Ele não publica porta e o
  painel só aceita origem da VPN. Mantenha assim.
- **Chaves.** O Core guarda o par de chaves no volume `komodo-keys`; cada agente grava a chave
  pública do Core na primeira conexão e passa a exigir a mesma. Se o volume do Core for apagado,
  os agentes recusam o Core novo: apague também o `komodo-periphery-keys` deles e refaça o onboarding.
- **Memória.** A Oracle tem pouca RAM; o Mongo está limitado a 0,25 GB de cache. Se apertar, troque
  para o FerretDB (`compose/ferretdb.compose.yaml` oficial). Mongo 5+ exige CPU com AVX.

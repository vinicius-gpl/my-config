# PLUTO

Desktop pessoal (Fedora). Não é gerenciado por Ansible nem pelas Actions: os serviços sobem com
`docker compose` direto das pastas deste repositório. Fica atrás de NAT, então tudo que é público
passa pela [Oracle](../oracle/README.md).

> Arquitetura completa, fluxos e diagnóstico: [**REDE.md**](../REDE.md).

| Item | Valor |
|---|---|
| IP na VPN (NetBird, `wt0`) | `100.96.62.172` (`pluto.netbird.selfhosted`) |
| Domínio dos serviços | `*.host.vinicius-gpl.com` |

## O que roda aqui

| Serviço | Compose | Endereço | Acesso |
|---|---|---|---|
| NetBird Client | systemd | `wt0` | — |
| Caddy local | `configuration/apps/caddy` | `:80` (HTTP, sem TLS) | via túnel da Oracle |
| Komodo Periphery | `configuration/apps/komodo` | conecta em `komodo.vinicius-gpl.com` | — |
| Sure (`sure-web`, `sure-worker`, `sure-db`, `sure-redis`) | `configuration/apps/sure` | `sure.host.vinicius-gpl.com` | público |

## Fluxo de um serviço público

```text
usuário → DNS Cloudflare → Oracle 168.138.133.78:443 (Caddy, TLS)
        → túnel NetBird → PLUTO 100.96.62.172:80 (Caddy local) → sure-web:3000
```

## Configuração

`configuration/apps/caddy/.env` (não versionado; modelo em `.env.example`):

```ini
EMAIL=contact@vinicius-gpl.com
DOMAIN=host.vinicius-gpl.com
CADDY_CONFIG_PATH=./config
CADDY_OPTS="auto_https off"
```

O Caddy local usa `config/caddyfile` (confia nos cabeçalhos vindos da VPN) e os sites de `config/conf.d/`.
`configuration/apps/sure/.env` segue o `.env.example` da pasta.

```bash
docker network create proxy                        # uma vez
docker compose -f configuration/apps/caddy/compose.yml up -d
docker compose -f configuration/apps/sure/compose.yml up -d
```

## Publicar um novo serviço

1. Conectar o container à rede `proxy` e criar `configuration/apps/caddy/config/conf.d/<app>.caddy`
   com `http://<app>.{$DOMAIN} { reverse_proxy <container>:<porta> }`.
2. Recarregar: `docker exec caddy caddy reload --config /etc/caddy/Caddyfile`.
3. Na Oracle: adicionar o nome em `caddy_tunnels[].hosts` de `configuration/servers/oracle/vars.yml`
   e rodar o deploy `caddy`.

# Servidor Oracle

VPS pública (`168.138.133.78`, Rocky Linux, usuário `rocky`) e borda de toda a rede:
termina o TLS, hospeda o NetBird e encaminha os serviços públicos do [PLUTO](../pluto/README.md).

| Item | Valor |
|---|---|
| IP público | `168.138.133.78` |
| IP na VPN (NetBird, `wt0`) | `100.96.113.83` (`vivy.netbird.selfhosted`) |
| Rede da VPN | `100.96.0.0/16` |
| Domínio | `vinicius-gpl.com` (zona na Cloudflare, modo "DNS only") |

## O que roda aqui

| Serviço | Onde | Endereço | Acesso |
|---|---|---|---|
| Caddy | Docker (`/opt/caddy`) | `:80`, `:443` | público |
| NetBird Server + Dashboard | Docker (`/opt/netbird`) | `netbird.vinicius-gpl.com`, `3478/udp` | público |
| NetBird Client | systemd (`netbird.service`) | `wt0` | — |
| Portainer | Docker (`/opt/portainer`) | `container.vinicius-gpl.com` | só VPN |
| Portainer Edge Tunnel | Docker (`/opt/portainer`) | `:8000` | público (agentes Edge) |
| Beszel Hub | Docker (`/opt/beszel-hub`) | `monitor.vinicius-gpl.com` | só VPN |
| Cockpit | systemd (`cockpit.socket`, `:9090`) | `cockpit.vinicius-gpl.com` | só VPN |
| Túnel para o PLUTO | Caddy (`conf.d/tunnel.caddy`) | `*.host.vinicius-gpl.com` | público |

Tudo que não é segredo fica em [`vars.yml`](vars.yml): sites do Caddy, hosts privados, túneis e IPs da VPN.

## DNS e acesso

Todo o domínio resolve pela Cloudflare; o NetBird não gerencia nenhuma zona de `vinicius-gpl.com`.

- **Públicos** (`netbird`, `*.host`): registro `A` → `168.138.133.78`.
- **Privados** (`container`, `monitor`, `cockpit`): registro `A` → `100.96.113.83`. Fora da VPN esse IP não é
  roteável; dentro dela o tráfego entra pelo túnel e o Caddy vê a origem `100.96.x.x`. O snippet `vpn_only`
  do Caddy ainda derruba qualquer origem fora de `vpn_cidr`.

Como a Let's Encrypt não alcança hosts que apontam para a VPN, os certificados usam o desafio DNS-01.
Isso é ativado pela secret **`CLOUDFLARE_API_TOKEN`** (permissão `Zone → DNS → Edit` na zona), que também
faz o deploy criar/atualizar os registros `A` privados e emitir o wildcard `*.host.vinicius-gpl.com`:

```bash
gh secret set CLOUDFLARE_API_TOKEN --env oracle
```

Sem a secret, o deploy usa a imagem oficial do Caddy, não toca no DNS e serve só os hosts listados em
`caddy_tunnels[].hosts`.

## Inventário

Cadastre a secret `ANSIBLE_HOSTS_INI` no Environment `oracle` (modelo em [`inventory.ini`](inventory.ini)):

```ini
[servers]
IP_DO_SERVIDOR_ORACLE ansible_user=rocky ansible_become=true ansible_ssh_forward_agent=true \
  domain=seusite.com \
  email=seu_email@dominio.com
```

## Deploy e limpeza via GitHub Actions

- **Ansible Deploy**: servidor `oracle`, etapa `caddy`, `netbird`, `portainer`, `beszel-hub`, `cockpit` ou `all`.
- **Ansible Clean**: servidor `oracle`, alvo desejado. Em `caddy`, marcar *remove_volumes* apaga `/opt/caddy`
  (configs) e preserva o volume `caddy-data` (certificados).

Localmente:

```bash
ansible-playbook -i configuration/servers/oracle/hosts.ini configuration/ansible/deploy.yml \
  -e @configuration/servers/oracle/vars.yml --tags caddy
```

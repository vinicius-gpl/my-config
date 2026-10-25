# Servidor Oracle

VPS pública (`168.138.133.78`, Rocky Linux, usuário `rocky`) e borda de toda a rede:
termina o TLS, hospeda o NetBird e encaminha os serviços públicos do [PLUTO](../pluto/README.md).

> Arquitetura completa, fluxos e diagnóstico: [**REDE.md**](../REDE.md).

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
| Komodo Core + Periphery | Docker (`/opt/komodo`, `/opt/komodo-periphery`) | `komodo.vinicius-gpl.com` | só VPN (`/listener/*` público) |
| Túnel para o PLUTO | Caddy (`conf.d/tunnel.caddy`) | hosts de `caddy_tunnels` em `*.host.vinicius-gpl.com` | público |

Tudo que não é segredo fica em [`vars.yml`](vars.yml): sites do Caddy, túneis e rede da VPN.

## DNS e acesso

Todo o domínio resolve pela Cloudflare e **todos os hosts apontam para o IP público** (`168.138.133.78`);
o NetBird não gerencia nenhuma zona de `vinicius-gpl.com`. Quem decide o acesso é o Caddy:

- **Privados** (`container`, `monitor`, `cockpit`): o snippet `vpn_only` derruba a conexão de qualquer
  origem fora de `vpn_cidr`.
  Para os peers chegarem com IP da VPN, o NetBird tem a rota `oracle-public-ip` (`168.138.133.78/32`,
  peer de roteamento: este servidor, sem masquerade; criada à mão no painel) e o host mantém esse IP no loopback (`vpn-public-ip.service`).
- **Públicos** (`netbird`, `*.host`): liberados para qualquer origem. Os hosts de `caddy_tunnels` seguem
  pelo túnel até o Caddy local do peer.

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

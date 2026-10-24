# Rede: Oracle, PLUTO e NetBird

Como os serviços são publicados, quem pode acessar cada um e por onde o tráfego passa.
Este é o documento central; os READMEs de cada servidor e app apontam para cá.

## Regra geral

1. **Todo o domínio resolve pela Cloudflare** e todos os nomes apontam para o IP público da Oracle.
   O NetBird não gerencia nenhuma zona de `vinicius-gpl.com`.
2. **Quem decide o acesso é o Caddy da Oracle**, pelo IP de origem da conexão:
   - serviços privados só aceitam origem dentro da VPN (`100.96.0.0/16`);
   - serviços públicos aceitam qualquer origem.
3. **Serviços do PLUTO são públicos por padrão**: o Caddy da Oracle termina o TLS e repassa pelo túnel
   da VPN para o Caddy local do PLUTO. Um túnel com `vpn_only: true` em `caddy_tunnels` aplica o mesmo
   filtro dos serviços privados.

## Mapa

| Máquina | Papel | IP público | IP na VPN (NetBird) |
|---|---|---|---|
| Oracle (`vivy`) | VPS Rocky Linux 9, borda pública, servidor NetBird | `168.138.133.78` | `100.96.113.83` |
| PLUTO | Desktop Fedora, serviços locais | atrás de NAT | `100.96.62.172` |
| Acerola | Servidor, agente Edge do Portainer | `178.105.95.169` | `100.96.151.221` |
| ALOHA-OE | Cliente Windows | — | `100.96.5.116` |
| BEBOP | Cliente Android | — | `100.96.10.180` |

- Rede da VPN: `100.96.0.0/16` (domínio interno `netbird.selfhosted`).
- DNS: zona `vinicius-gpl.com` na Cloudflare, registros `A` em modo "DNS only" (sem proxy).
- Dentro da Oracle Cloud a interface `eth0` tem só o IP interno `10.0.0.128`; o IP público é NAT 1:1.

## Nomes e acesso

Todos resolvem para `168.138.133.78`.

| Nome | Serviço | Roda em | Acesso | Definido em |
|---|---|---|---|---|
| `netbird.vinicius-gpl.com` | NetBird (painel, API, signal, relay) | Oracle | público | `apps/netbird/config/netbird.caddy` |
| `container.vinicius-gpl.com` | Portainer | Oracle | só VPN | `apps/portainer/config/portainer.caddy` |
| `monitor.vinicius-gpl.com` | Beszel Hub | Oracle | só VPN | `apps/beszel/config/beszel.caddy` |
| `cockpit.vinicius-gpl.com` | Cockpit | Oracle | só VPN | `apps/cockpit/cockpit.caddy` |
| `sure.host.vinicius-gpl.com` | Sure | PLUTO | público | Oracle: `caddy_tunnels` em `servers/oracle/vars.yml`; PLUTO: `apps/caddy/config/conf.d/sure.caddy` |
| `ai-memory.host.vinicius-gpl.com` | ai-memory (web UI e MCP) | PLUTO | só VPN | Oracle: `caddy_tunnels` (`vpn_only: true`) em `servers/oracle/vars.yml`; PLUTO: `apps/caddy/config/conf.d/ai-memory.caddy` |

`*.host.vinicius-gpl.com` tem registro wildcard no DNS, mas a Oracle só atende os nomes listados em
`caddy_tunnels[].hosts`. Um nome não listado tem a conexão TLS recusada, e por isso ninguém consegue
forçar a emissão de certificados para subdomínios arbitrários.

## Fluxo de um serviço privado

```text
Fora da VPN
  cliente ──internet──▶ 168.138.133.78:443 ──▶ Caddy vê o IP público do cliente ──▶ conexão derrubada

Dentro da VPN
  cliente ──túnel NetBird──▶ 168.138.133.78:443 ──▶ Caddy vê 100.96.x.x ──▶ Portainer / Beszel / Cockpit
```

O nome e o IP de destino são os mesmos nos dois casos; muda só o caminho. Três peças fazem isso funcionar:

### 1. Snippet `vpn_only` no Caddy

Definido em `apps/caddy/config/caddyfile.edge` e importado pelos três sites privados:

```caddyfile
(vpn_only) {
    @fora_da_vpn not remote_ip {$VPN_CIDR}
    abort @fora_da_vpn
}
```

`VPN_CIDR` vem de `vpn_cidr` em `servers/oracle/vars.yml`. `abort` fecha a conexão sem resposta HTTP
(no `curl`, erro 92 ou resposta vazia).

### 2. Rota no NetBird

Sem rota, um peer manda o tráfego para `168.138.133.78` pela internet, mesmo com a VPN ligada, e o
Caddy enxerga o IP público dele. A rota faz esse destino sair pelo túnel:

| Campo | Valor |
|---|---|
| Nome | `oracle-public-ip` |
| Network Range | `168.138.133.78/32` |
| Routing Peer | `VIVY` (Oracle) |
| Distribution Groups | `All` |
| Masquerade | **desligado** (com ele ligado o Caddy veria o IP da própria Oracle) |
| Metric | `9999` |

A rota é criada à mão no painel e **não é gerenciada pelo Ansible**. Para recriar:
`https://netbird.vinicius-gpl.com/network-routes` → **Add Route** → preencher os campos acima.

Efeitos da rota em todo peer da VPN: SSH e HTTPS para a Oracle passam pelo túnel, e o agente Edge do
Portainer na Acerola fala com `container.vinicius-gpl.com` pela VPN.

### 3. IP público no loopback da Oracle

O pacote chega pelo túnel com destino `168.138.133.78`, mas a Oracle só conhece `10.0.0.128`. O
serviço `vpn-public-ip.service` adiciona `168.138.133.78/32` à interface `lo`, e assim o host aceita o
tráfego como local e o Docker o entrega ao Caddy. É criado pelo deploy do `caddy` quando
`vpn_routed_public_ip` está definido em `vars.yml`, e removido pelo clean do `caddy`.

## Fluxo de um serviço público do PLUTO

```text
usuário ─▶ DNS Cloudflare ─▶ Oracle 168.138.133.78:443 (Caddy, TLS da Let's Encrypt)
        ─▶ túnel NetBird  ─▶ PLUTO 100.96.62.172:80 (Caddy local, HTTP)
        ─▶ sure-web:3000
```

- Na Oracle, `conf.d/tunnel.caddy` é gerado de `apps/caddy/config/tunnel.caddy.j2` com os dados de
  `caddy_tunnels`.
- No PLUTO, o Caddy roda sem TLS (`CADDY_OPTS="auto_https off"`) e confia nos cabeçalhos
  `X-Forwarded-*` vindos da VPN (`trusted_proxies` em `apps/caddy/config/caddyfile`).

## Os dois Caddys

| | Oracle (borda) | PLUTO (local) |
|---|---|---|
| Como sobe | Ansible / GitHub Actions, em `/opt/caddy` | `docker compose` direto do repo |
| Caddyfile | `apps/caddy/config/caddyfile.edge` | `apps/caddy/config/caddyfile` |
| Sites | `caddy_sites` + `tunnel.caddy` (ver `vars.yml`) | `apps/caddy/config/conf.d/*.caddy` |
| TLS | Let's Encrypt automático | desligado |
| Compose | `apps/caddy/compose.yml` (o mesmo nos dois) | |

O deploy da Oracle roda `caddy validate` com a configuração nova antes de recriar o container; se a
configuração estiver inválida, o deploy falha e o container em execução não é recriado.

## Portas na Oracle

| Porta | Serviço | Alcançável da internet |
|---|---|---|
| `80`, `443` | Caddy | sim |
| `3478/udp` | NetBird (STUN/relay) | sim |
| `8000` | Portainer Edge Tunnel | sim |
| `8090` | Beszel Hub (direto) | não |
| `9090` | Cockpit (direto) | não |
| `9443` | Portainer (direto) | não |

As portas `8090`, `9090` e `9443` estão publicadas no host, mas não respondem de fora: o firewalld da VM as libera, então o
bloqueio acontece antes dela (regras de rede da Oracle Cloud; não conferido no console). O acesso a esses serviços é sempre pelo Caddy.

## Operação

Deploy e limpeza pelas Actions (**Ansible Deploy** / **Ansible Clean**, servidor `oracle`). O workflow
carrega `servers/oracle/vars.yml` automaticamente. Localmente:

```bash
ansible-playbook -i configuration/servers/oracle/hosts.ini configuration/ansible/deploy.yml \
  -e @configuration/servers/oracle/vars.yml --tags caddy
```

O clean do `caddy` com *remove_volumes* apaga `/opt/caddy` (configurações) e preserva o volume
`caddy-data` (certificados). Entre o clean e o deploy todos os sites ficam fora, inclusive o painel do
NetBird; os clientes reconectam sozinhos.

### Publicar um serviço privado na Oracle

1. Criar o `.caddy` do app começando com `import vpn_only`.
2. Adicionar o caminho em `caddy_sites` de `servers/oracle/vars.yml`.
3. Criar o registro `A` na Cloudflare → `168.138.133.78` (DNS only).
4. Rodar o deploy `caddy`.

### Publicar um serviço público do PLUTO

1. No PLUTO: conectar o container à rede `proxy` e criar `apps/caddy/config/conf.d/<app>.caddy` com
   `http://<app>.{$DOMAIN} { reverse_proxy <container>:<porta> }`; recarregar com
   `docker exec caddy caddy reload --config /etc/caddy/Caddyfile`.
2. Adicionar o nome em `caddy_tunnels[].hosts` de `servers/oracle/vars.yml` e rodar o deploy `caddy`.
   O DNS já cobre o nome pelo wildcard `*.host`.
3. Para deixá-lo só na VPN, colocar o nome num túnel com `vpn_only: true`. No PLUTO, o `.caddy` do app
   deve aceitar só `remote_ip 100.96.113.83` (a Oracle): a porta 80 do PLUTO é alcançável pela LAN, e
   sem isso daria para contornar o filtro da Oracle (ver `conf.d/ai-memory.caddy`).

O ai-memory roda no host (serviço systemd do usuário, ouvindo só em `127.0.0.1:49374`). O Caddy, no
Docker, chega nele por `ai-memory-proxy.socket` (`~/.config/systemd/user/`), que escuta em
`172.18.0.1:49374` (gateway da rede `proxy`) e repassa para o loopback. O nome também precisa estar em
`allowed_hosts` de `~/.local/share/ai-memory/config.toml`.

## Diagnóstico

```bash
# No cliente: o IP público da Oracle deve sair pelo túnel (dev wt0)
ip route get 168.138.133.78
netbird networks list                 # oracle-public-ip → Selected

# Acesso pelo nome (na VPN: 200; fora: conexão derrubada)
curl -sI https://container.vinicius-gpl.com

# Na Oracle
ip -br addr show lo                   # deve listar 168.138.133.78/32
systemctl status vpn-public-ip.service
ls /opt/caddy/conf.d
docker exec caddy tail -n 5 /data/portainer-access.log   # campo remote_ip = origem vista pelo Caddy
```

| Sintoma | Causa provável |
|---|---|
| Privado recusa mesmo na VPN e `ip route get` mostra a interface de internet | rota `oracle-public-ip` ausente, desativada ou não selecionada no cliente |
| Privado dá timeout na VPN e `ip route get` mostra `wt0` | `vpn-public-ip.service` parado na Oracle (IP fora do `lo`) |
| Privado recusa na VPN e o log mostra `remote_ip` da própria Oracle | masquerade ligado na rota |
| `*.host` novo com erro de TLS | nome não está em `caddy_tunnels[].hosts` |
| `sure.host` responde 502 | peer PLUTO desconectado, ou Caddy/Sure parados no PLUTO |
| Todos os sites fora | container `caddy` parado na Oracle |

## Pendências conhecidas

- A rota `oracle-public-ip` existe só no banco do NetBird; se o servidor NetBird for recriado do zero,
  precisa ser refeita à mão.
- A porta `8000` (Portainer Edge Tunnel) é pública.
- O site `vpn.vinicius-gpl.com` (`wireguard.caddy`) não é implantado na Oracle: não há WireGuard lá.

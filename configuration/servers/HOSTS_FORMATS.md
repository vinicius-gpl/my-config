# 📋 Guia de Formatos do `hosts.ini` (Inventário Ansible)

Este documento detalha todos os formatos aceitos pelo Ansible no repositório, quais variáveis são necessárias para cada app e exemplos prontos para copiar e colar nas Secrets (`ANSIBLE_HOSTS_INI`).

---

## 📌 Estrutura Geral de uma Linha no `hosts.ini`

Cada servidor é declarado sob o grupo `[servers]` (ou `[relay_servers]`), seguido pelo **IP ou Domínio** e suas variáveis em formato `chave=valor`:

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root variavel1=valor variavel2=valor
```

---

## 1. Formato: Servidor Relay (Acerola)
> **Apps típicos:** Caddy (Reverse Proxy com SSL) + WireGuard (wg-easy) + Portainer + Beszel Agent.

```ini
[servers]
192.168.0.1 ansible_user=root ansible_ssh_forward_agent=true \
  email=admin@meudominio.com \
  domain=meudominio.com \
  wg_host=meudominio.com \
  wg_password=MinhaSenhaForteDaVPN123 \
  beszel_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... chave_gerada_pelo_hub"
```

### O que cada variável faz:
* `email`: Registrado no Caddy para emitir e renovar certificados TLS/HTTPS automáticos (Let's Encrypt).
* `domain`: O domínio base. Cria automaticamente:
  * `vpn.meudominio.com` (Painel do WireGuard / wg-easy)
  * `container.meudominio.com` (Painel do Portainer)
  * `monitor.meudominio.com` (Painel do Beszel Hub, se instalado)
* `wg_host`: *(Opcional)* IP público ou domínio DNS real usado como `Endpoint` nos clientes WireGuard (ex: `200.x.x.x` ou `vpn.meudominio.com`). Se omitido, usa o `domain` ou o IP do host.
* `wg_password`: A senha de acesso à interface Web do WireGuard (convertida automaticamente em bcrypt hash).
* `beszel_key`: A chave pública gerada pelo Beszel Hub para que o Beszel Agent monitore esta máquina.

---

## 2. Formato: Servidor Oracle Cloud (VPS com usuário não-root)
> **Importante na Oracle:** O usuário padrão geralmente é `ubuntu` ou `opc`, e é necessário habilitar elevação de privilégios (`ansible_become=true`).

```ini
[servers]
150.136.x.x ansible_user=ubuntu ansible_become=true ansible_ssh_forward_agent=true \
  email=admin@meudominio.com \
  domain=oracle.meudominio.com \
  beszel_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... chave_gerada_pelo_hub"
```

> **Atenção:** Como o usuário é `ubuntu`, cadastre a senha do `sudo` na secret **`ANSIBLE_BECOME_PASSWORD`** (ou `ORACLE_ANSIBLE_BECOME_PASSWORD`).

---

## 3. Formato: Servidor Beszel Hub (Central de Monitoramento)
> Se você subir o **Beszel Hub** (`--tags beszel-hub`), ele criará o painel Web de monitoramento em `http://IP:8090` (ou `https://monitor.meudominio.com` via Caddy).

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  email=admin@meudominio.com \
  domain=meudominio.com
```

---

## 4. Formato: Servidor com Coolify e Supabase (Stack de Desenvolvimento)

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  domain=meudominio.com \
  beszel_key=CHAVE_DO_BESZEL_HUB \
  coolify_root_email=admin@meudominio.com \
  coolify_root_password=MinhaSenhaForteCoolifyAa1! \
  coolify_app_id=GERE_HEX_16 \
  coolify_app_key=base64:GERE_BASE64_32 \
  coolify_db_password=GERE_HEX_24 \
  coolify_redis_password=GERE_HEX_24 \
  coolify_pusher_app_id=GERE_HEX_16 \
  coolify_pusher_app_key=GERE_HEX_32 \
  coolify_pusher_app_secret=GERE_HEX_32 \
  supabase_postgres_password=GERE_BASE64_18 \
  supabase_jwt_secret=GERE_HEX_32 \
  supabase_anon_key=JWT_ANON_ASSINADO \
  supabase_service_role_key=JWT_SERVICE_ASSINADO \
  supabase_dashboard_password=GERE_BASE64_18 \
  supabase_secret_key_base=GERE_HEX_32 \
  supabase_realtime_enc_key=GERE_HEX_8 \
  supabase_profiles=
```

---

## 5. Formato: Servidor NetBird (VPN Mesh & Zero Trust)
> Sobe o NetBird Server (Management + Signal + Relay) e Dashboard em `https://netbird.meudominio.com`.

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root domain=meudominio.com email=admin@meudominio.com
```

* Os segredos de sessão, datastore e relay são gerados automaticamente pelo Ansible se não informados.
* No primeiro acesso, o painel solicita a criação do usuário Administrador local (e-mail e senha).

---

## 6. Formato: Cliente NetBird (Ingressar Nó na VPN)
> Instala e conecta o cliente NetBird automaticamente usando a Setup Key gerada no painel web.

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root domain=acerola.app netbird_setup_key="CHAVE_SETUP_KEY_DO_PAINEL"
```

* `netbird_setup_key`: A chave gerada no menu **Setup Keys** do seu painel NetBird.
* `netbird_mgmt_url`: *(Opcional)* URL de gerenciamento da sua VPN. Se omitido, assume `https://netbird.{{ domain }}`.

---

## 7. Formato: NetBird Reverse Proxy (Proxy Reverso Privado)
> Sobe o container oficial do NetBird Reverse Proxy (`netbirdio/reverse-proxy:0.80.0`) para expor serviços privados nas portas 80 e 443 com ACME automático.

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  netbird_proxy_token="SEU_TOKEN_DO_NETBIRD_PROXY" \
  netbird_proxy_domain="proxy.meudominio.com" \
  netbird_proxy_address="https://netbird.meudominio.com:443"
```

* `netbird_proxy_token`: Token gerado no NetBird para autorizar o proxy reverso.
* `netbird_proxy_domain`: Domínio gerenciado pelo proxy (`NB_PROXY_DOMAIN`).
* `netbird_proxy_address`: Endereço do NetBird Management Server (`NB_PROXY_MANAGEMENT_ADDRESS`).

---

## 8. Formato: Portainer Edge Agent (Conectar Worker ao Portainer Central)
> Conecta este servidor como nó Edge ao Portainer Server central (ex: na Oracle) via Edge ID e Edge Key.

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  domain=acerola.app \
  portainer_edge_id="EDGE_ID_GERADO_NO_PORTAINER" \
  portainer_edge_key="EDGE_KEY_GERADA_NO_PORTAINER"
```

* `portainer_edge_id`: O ID do Edge Environment gerado no Portainer (`Environments` -> `Add environment` -> `Edge Agent Docker`).
* `portainer_edge_key`: A chave Edge Key completa gerada pelo Portainer no mesmo formulário.

---

## 9. Formato: Servidor All-in-One (100% de Todos os Serviços)
> Se você quiser subir **absolutamente tudo** do repositório em um único servidor (Caddy, Portainer, WireGuard, NetBird Server, NetBird Client, Beszel Hub, Beszel Agent, Coolify, Supabase, Cockpit):

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  domain=meudominio.com \
  email=admin@meudominio.com \
  wg_host=meudominio.com \
  wg_password=MinhaSenhaForteDaVPN123 \
  wg_allowed_ips="10.0.0.0/24, IP_DO_SERVIDOR/32" \
  beszel_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... chave_gerada_pelo_hub" \
  netbird_auth_secret=0123456789abcdef0123456789abcdef \
  netbird_session_key="GERE_BASE64_32_AQUI==" \
  netbird_datastore_key="GERE_BASE64_32_AQUI==" \
  netbird_setup_key="CHAVE_SETUP_KEY_DO_PAINEL" \
  netbird_mgmt_url=https://netbird.meudominio.com \
  coolify_root_email=admin@meudominio.com \
  coolify_root_password=MinhaSenhaForteCoolifyAa1! \
  coolify_app_id=0123456789abcdef \
  coolify_app_key=base64:GERE_BASE64_32_AQUI== \
  coolify_db_password=SenhaForteBancoCoolify123! \
  coolify_redis_password=SenhaForteRedisCoolify123! \
  coolify_pusher_app_id=0123456789abcdef \
  coolify_pusher_app_key=0123456789abcdef0123456789abcdef \
  coolify_pusher_app_secret=0123456789abcdef0123456789abcdef \
  supabase_postgres_password=SenhaFortePostgresSupabase123! \
  supabase_jwt_secret=0123456789abcdef0123456789abcdef \
  supabase_anon_key=JWT_ANON_ASSINADO_AQUI \
  supabase_service_role_key=JWT_SERVICE_ROLE_ASSINADO_AQUI \
  supabase_dashboard_password=SenhaForteDashboardSupabase123! \
  supabase_secret_key_base=0123456789abcdef0123456789abcdef \
  supabase_realtime_enc_key=01234567 \
  supabase_profiles=
```

---

## 📖 Dicionário de Todas as Variáveis Possíveis

| Variável | Aplicação / Escopo | Obrigatória? | Descrição |
| :--- | :--- | :---: | :--- |
| **`ansible_user`** | Conexão SSH | **Sim** | Usuário de acesso SSH (`root`, `ubuntu`, `opc`). |
| **`ansible_become`** | Conexão SSH | Não | `true` se o usuário não for root e precisar de `sudo`. |
| **`ansible_ssh_forward_agent`** | Conexão SSH | Não | `true` para usar chaves SSH do agente local. |
| **`domain`** | Caddy / Geral | **Sim** | Domínio base raiz (ex: `meudominio.com`). Gera automaticamente os subdomínios (`vpn.`, `container.`, `monitor.`, `netbird.`). |
| **`email`** | Caddy (SSL) | **Sim** | E-mail registrado no Let's Encrypt / ZeroSSL para emissão automática de HTTPS. |
| **`wg_host`** | WireGuard | Não | IP público ou domínio DNS real usado como `Endpoint` no arquivo de configuração do cliente VPN. |
| **`wg_password`** | WireGuard | Não | Senha da interface web do `wg-easy` (convertida automaticamente em bcrypt hash). |
| **`wg_allowed_ips`** | WireGuard | Não | Faixas de IP que o cliente VPN vai rotear pelo túnel (Split Tunneling). |
| **`beszel_key`** | Beszel Agent | Não | Chave pública gerada pelo Beszel Hub para autorizar este agente a enviar métricas. |
| **`portainer_edge_id`** | Portainer Edge Agent | Não | ID do Edge Environment gerado no painel do Portainer Server. |
| **`portainer_edge_key`** | Portainer Edge Agent | Não | Chave Edge Key gerada no Portainer Server para conexão do nó remoto. |
| **`netbird_setup_key`** | NetBird Client | Não | Chave gerada no painel NetBird para ingressar o servidor na VPN automaticamente. |
| **`netbird_mgmt_url`** | NetBird Client | Não | URL do servidor de controle NetBird. Default: `https://netbird.{{ domain }}`. |
| **`netbird_auth_secret`** | NetBird Server | Não | Segredo de autenticação do Relay (mínimo 32 caracteres hex). Gerado automaticamente se omitido. |
| **`netbird_session_key`** | NetBird Server | Não | Chave de criptografia da sessão de cookies (base64 de 32 bytes). Gerada automaticamente se omitida. |
| **`netbird_datastore_key`** | NetBird Server | Não | Chave de criptografia do banco SQLite (base64 de 32 bytes). Gerada automaticamente se omitida. |
| **`netbird_proxy_token`** | NetBird Reverse Proxy | Não* | Token gerado no NetBird para autenticar e registrar o container do proxy reverso. |
| **`netbird_proxy_domain`** | NetBird Reverse Proxy | Não* | Domínio atendido pelo proxy reverso (onde os certificados ACME são provisionados). |
| **`netbird_proxy_address`** | NetBird Reverse Proxy | Não* | Endereço do NetBird Management Server (`NB_PROXY_MANAGEMENT_ADDRESS`). |
| **`coolify_root_email`** | Coolify | Não | E-mail do usuário administrador criado no primeiro boot. |
| **`coolify_root_password`**| Coolify | Não | Senha do usuário administrador inicial do Coolify. |
| **`coolify_app_id`** | Coolify | Não | ID único da instância do Coolify (16 caracteres hex). |
| **`coolify_app_key`** | Coolify | Não | Chave de cifra mestra do Laravel (`base64:...` com 32 bytes). |
| **`coolify_db_password`** | Coolify | Não | Senha do banco PostgreSQL interno do Coolify. |
| **`coolify_redis_password`**| Coolify | Não | Senha do Redis interno do Coolify. |
| **`coolify_pusher_app_id`** | Coolify | Não | ID do servidor de websockets em tempo real (16 chars). |
| **`coolify_pusher_app_key`**| Coolify | Não | Chave do servidor de websockets em tempo real (32 chars). |
| **`coolify_pusher_app_secret`**| Coolify | Não | Segredo do servidor de websockets em tempo real (32 chars). |
| **`supabase_postgres_password`**| Supabase | Não | Senha do banco PostgreSQL principal do Supabase. |
| **`supabase_jwt_secret`** | Supabase | Não | Segredo HMAC-SHA256 usado para assinar os tokens JWT (32 chars). |
| **`supabase_anon_key`** | Supabase | Não | Token JWT com role `anon` assinado com o `supabase_jwt_secret`. |
| **`supabase_service_role_key`**| Supabase| Não | Token JWT com role `service_role` com privilégios administrativos. |
| **`supabase_dashboard_password`**| Supabase| Não | Senha do painel web Studio do Supabase (usuário padrão: `supabase`). |
| **`supabase_secret_key_base`**| Supabase | Não | Chave mestra de 32 caracteres usada pelo serviço Realtime. |
| **`supabase_realtime_enc_key`**| Supabase| Não | Chave de 8 caracteres usada para cifrar mensagens em tempo real. |
| **`supabase_profiles`** | Supabase | Não | Perfis adicionais do Compose para ativar (`analytics,realtime,storage,edge-runtime`). |

---

## 🛠️ Geradores Rápidos de Segredos

Se precisar gerar chaves aleatórias no terminal para colocar no `hosts.ini`:

```bash
# Hexadecimal de 16 ou 32 caracteres:
openssl rand -hex 16
openssl rand -hex 32

# Chave Base64 (para Coolify app_key):
printf 'base64:%s\n' "$(openssl rand -base64 32)"
```


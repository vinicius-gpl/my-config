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
* Você pode configurar o login via GitHub OAuth diretamente no painel web em **Settings > Identity Providers**.

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

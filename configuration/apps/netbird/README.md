# 🦅 NetBird Self-Hosted Guide

O **NetBird** é uma solução de VPN Mesh moderna baseada em **WireGuard**, 100% de código aberto, com controle de acesso granular (ACLs), grupos de usuários, roteamento de sub-redes e suporte a NAT Traversal P2P automático.

---

## 🏛️ Arquitetura

O deploy utiliza a arquitetura moderna combinada do NetBird:
* **`netbird-server`**: Container unificado que engloba Management API, Signal Exchange, Relay (STUN/TURN) e IdP embarcado (Dex).
* **`netbird-dashboard`**: Interface gráfica moderna para gestão de peers, ACLs e regras.
* **`Caddy`**: Proxy reverso com suporte a **HTTP/2 cleartext (h2c)** e **gRPC**, emitindo certificado SSL automático para `https://netbird.seu-dominio.com`.

---

## 🔑 Autenticação e Usuários

O NetBird moderno possui um **Identity Provider (IdP) embarcado** (Dex) nativo com gerenciamento local de usuários por e-mail e senha, sem exigir provedores externos.

### Primeiro Acesso:
1. Ao acessar `https://netbird.seu-dominio.com` pela primeira vez, o assistente solicitará a criação da sua conta de Administrador inicial (e-mail e senha).
2. Após o login, você tem acesso total ao painel.
3. Para gerenciar usuários, acesse **Team > Users** e convide novos membros ou crie novas credenciais.
4. Para conectar servidores automaticamente (sem login interativo), gere uma chave em **Setup Keys**.

---

## 📋 Configuração no `hosts.ini`

Basta declarar o servidor sob `[servers]` com seu domínio. O Ansible gera automaticamente as chaves criptográficas necessárias se você não as fornecer:

```ini
[servers]
IP_DO_SERVIDOR ansible_user=root domain=seu-dominio.com email=admin@seu-dominio.com
```

### Variáveis Opcionais (se quiser fixar seus próprios segredos):
* `netbird_auth_secret`: Segredo compartilhado de autenticação do Relay (mínimo 32 caracteres hex).
* `netbird_session_key`: Chave de criptografia de sessão de cookie (32 caracteres).
* `netbird_datastore_key`: Chave de criptografia do banco de dados SQLite (32 caracteres).

---

## 🚀 Como fazer Deploy

### Via GitHub Actions:
1. Vá na aba **Actions** > **Ansible Deploy** > **Run workflow**.
2. Selecione o servidor alvo: `oracle` (ou `acerola`).
3. Selecione a etapa: **`netbird`**.
4. Clique em **Run workflow**.

### Via Terminal (Ansible local):
```bash
ansible-playbook -i configuration/servers/oracle/inventory.ini configuration/ansible/deploy.yml --tags "base,caddy,netbird"
```

---

## 📱 Conectando seus Clientes (Windows, Mac, Linux, Android, iOS)

1. Baixe o app oficial do [NetBird](https://netbird.io/docs/how-to-guides/getting-started).
2. Nas configurações do app (Settings / Advanced):
   * Troque a URL de gerenciamento para o seu servidor: `https://netbird.seu-dominio.com`.
3. Clique em **Connect** / **Login**.
4. Faça login com o seu usuário e senha. O dispositivo será pareado instantaneamente!

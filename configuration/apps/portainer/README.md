# 🚢 Portainer Business Edition — Servidor Central & Edge Agents

Este diretório contém a infraestrutura e templates para o gerenciamento centralizado de containers Docker via **Portainer Business Edition**, com suporte a nós remotos (**Edge Agents**).

---

## 🏛️ Arquitetura de Rede

```text
┌──────────────────────────────────────┐             ┌──────────────────────────────────┐
│        ORACLE CLOUD (CENTRAL)        │             │         ACEROLA (WORKER)         │
│                                      │             │                                  │
│  Caddy (Reverse Proxy)               │             │  Portainer Edge Agent            │
│  └── 443 -> portainer:9443 (HTTPS)   │  ◄─ HTTPS ──┼─── Heartbeat / Poll API          │
│                                      │             │    (container.vinicius-gpl.com)  │
│  Portainer Server (EE 2.45.2)        │             │                                  │
│  └── Porta 8000 (TCP Edge Tunnel)    │  ◄── TCP ───┼─── Reverse Management Tunnel     │
│                                      │             │    (Porta 8000)                  │
└──────────────────────────────────────┘             └──────────────────────────────────┘
```

* **Servidor Central (Oracle):** Roda o container `portainer/portainer-ee:lts` com persistência no volume `portainer-data` e proxy reverso no Caddy em `https://container.vinicius-gpl.com`.
* **Nós Remotos (Acerola e outros workers):** Rodam o container `portainer_edge_agent` (`portainer/agent:2.45.2`), conectando-se de dentro para fora (outbound) na Oracle via túnel reverso.

---

## 🔌 Portas e Regras de Firewall

| Porta | Protocolo | Onde é aberta? | Função |
| :---: | :---: | :--- | :--- |
| **`443`** | TCP | Oracle (Caddy) | Interface Web do Portainer e chamadas de API/Heartbeat do Agent. |
| **`8000`** | TCP | Oracle (Firewalld + OCI) | **Túnel Reverso do Edge Agent** (sessões interativas de console, logs e gestão). |
| **`9443`** | TCP | Interno Oracle | Porta HTTPS interna do container Portainer (proxied pelo Caddy). |
| **`9001`** | TCP | Workers | Porta do agente tradicional (não utilizada no modo Edge). |

> [!IMPORTANT]
> A porta **8000 (TCP)** precisa obrigatoriamente estar liberada na **Security List da VCN da Oracle Cloud** (Ingress Rule: CIDR `0.0.0.0/0`, Protocolo TCP, Porta 8000), além do firewalld do host.

---

## 🚀 Como Fazer o Deploy

### 1. Servidor Central (Oracle)
1. Rode o GitHub Action **Ansible Deploy**:
   - `server`: `oracle`
   - `step`: `portainer`
2. No primeiro acesso (`https://container.vinicius-gpl.com`), crie o usuário admin e insira a licença.
3. **Passo Crucial:** No menu da esquerda, vá em **Settings** > **Edge Compute**:
   - **Portainer API Server URL:** `https://container.vinicius-gpl.com`
   - **Portainer tunnel address:** `container.vinicius-gpl.com:8000`
   - Salve as configurações.

---

### 2. Conectar um Servidor Remoto (Acerola / Workers)
1. No Portainer Central, vá em **Environments** > **Add environment** > **Edge Agent Docker**.
2. Dê um nome ao ambiente (ex: `Acerola`).
3. O Portainer exibirá o comando com o `EDGE_ID` e a `EDGE_KEY`.
4. Cadastre as duas variáveis no seu `inventory.ini` ou na Secret `ACEROLA_ANSIBLE_HOSTS_INI`:
   ```ini
   [servers]
   178.105.95.169 ansible_user=root ansible_ssh_forward_agent=true \
     domain=acerola.app \
     portainer_edge_id="SEU_EDGE_ID" \
     portainer_edge_key="SUA_EDGE_KEY"
   ```
5. Rode a Action **Ansible Deploy**:
   - `server`: `acerola`
   - `step`: `portainer-agent`
6. O status no painel mudará para **Heartbeat (verde)** e a gestão dos containers estará disponível.

---

## 🔧 Troubleshooting

### "There was an issue connecting to edge agent via tunnel"
* **Causa:** O *Heartbeat* (porta 443) funcionou, mas o túnel SSH/TCP (porta 8000) não conseguiu conectar na Oracle.
* **Solução:**
  1. Verifique se a porta **8000/tcp** está liberada nas Ingress Rules da Oracle Cloud (OCI).
  2. Verifique se o **Portainer tunnel address** em *Settings > Edge Compute* está configurado como `container.vinicius-gpl.com:8000` (e não `localhost:8000`).
  3. Se alterou o tunnel address depois de gerar a chave, exclua o ambiente no Portainer, recrie-o para obter a nova chave e atualize a secret do GitHub.

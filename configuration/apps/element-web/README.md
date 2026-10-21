# Element Web (Matrix Chat & Messaging)

Cliente web oficial para comunicação descentralizada Matrix (alternativa self-hosted a Slack, Discord e Microsoft Teams).

---

## 🏗️ Arquitetura

O **Element Web** atua como o frontend visual de mensagens e colaboração, conectando-se diretamente ao **Matrix Synapse** (`call.{$DOMAIN}`):

```text
[Navegador / App] 
       │
       ▼
 [Caddy Proxy] (TLS automático em chat.{$DOMAIN} e element.{$DOMAIN})
       │
       ├── /* ────────► [element-web:80] (SPA estático)
       │
       └── /_matrix/* ──► [element-synapse:8008] (API Matrix)
```

### Recursos Integrados:
- **Salas & Mensagens:** Mensagens diretas, canais públicos/privados, threads e formatação rica.
- **Criptografia E2EE:** Criptografia de ponta a ponta nativa com suporte a verificação cruzada de dispositivos.
- **Element Call Integrado:** Botão de chamada de voz/vídeo em grupo dentro de cada sala, utilizando a stack MatrixRTC/LiveKit já configurada.

---

## 🚀 Deploy e Operação

### Deploy via GitHub Actions
1. Vá em **Actions** > **Ansible Deploy** > **Run workflow**.
2. Servidor alvo: `oracle` (ou `acerola`).
3. App / Etapa: `element-web`.
4. Clique em **Run workflow**.

### Acesso:
- URL principal: `https://chat.<seu-dominio>`
- URL alternativa: `https://element.<seu-dominio>`

Ao abrir o endereço, o homeserver já vem pré-configurado para `https://call.<seu-dominio>`, permitindo login imediato com a sua conta ou criação de novo usuário.

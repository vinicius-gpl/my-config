# 📞 Element Call Self-Hosted (MatrixRTC + LiveKit)

O **Element Call** é a plataforma de videoconferência com criptografia ponta-a-ponta (E2EE) construída sobre o protocolo **MatrixRTC** ([MSC4143](https://github.com/matrix-org/matrix-spec-proposals/pull/4143) / [MSC4195](https://github.com/matrix-org/matrix-spec-proposals/pull/4195)) e **LiveKit SFU**.

---

## 🏛️ Por que existem 4 containers no `compose.yml`?

O repositório `element-hq/element-call` é apenas o **frontend web (React SPA)** da ferramenta de chamadas da Element. Nas versões atuais (branch padrão `livekit`), a própria Element substituiu o modo antigo P2P (*full-mesh*) pelo **MatrixRTC + LiveKit** para suportar chamadas em grupo sem travar.

Por isso, tudo sobe junto sob o mesmo domínio (`https://call.<domain>`):

| Container | Imagem | Papel | Rota no Caddy |
|---|---|---|---|
| `element-call` | `ghcr.io/element-hq/element-call:v0.28.0` | Interface web oficial do Element Call | `/*` |
| `element-synapse` | `ghcr.io/element-hq/synapse:v1.163.0` | Servidor Matrix que guarda usuários, credenciais e salas | `/_matrix/*`, `/.well-known/matrix/*` |
| `element-lk-jwt` | `ghcr.io/element-hq/lk-jwt-service:v0.9.0` | Ponte oficial da Element que valida o login e gera o token da chamada | `/livekit/jwt/*` |
| `element-livekit` | `livekit/livekit-server:v1.13.10` | Motor de mídia WebRTC (áudio, vídeo e compartilhamento de tela) | `/livekit/sfu/*` + `7881/tcp` e `50100-50200/udp` |

---

## 🔑 Privacidade por Credencial (Login e Senha Nativos)

O serviço fica **acessível pela internet** (sem exigir VPN dos participantes), mas **fechado por credencial**:

1. **Registro público desativado (`enable_registration: false`)**:
   * Ninguém consegue criar conta por conta própria nem iniciar/entrar em chamadas como anônimo sem estar autenticado.
2. **Tela de Login nativa (`/login`)**:
   * O próprio Element Call possui a rota `https://call.<domain>/login`.
   * Você entra com seu usuário e senha cadastrados no `element-synapse` e cria/participa das salas.
3. **Criação automática do primeiro usuário no Ansible**:
   * O deploy já cria automaticamente o usuário inicial (`element_call_user`, padrão `admin`) no Synapse.
   * Para adicionar mais usuários depois (para amigos/convidados):
     ```bash
     docker exec -it element-synapse register_new_matrix_user \
       -c /etc/synapse/homeserver.yaml http://localhost:8008
     ```

---

## ⚙️ Variáveis no Ansible

Você **não é obrigado** a passar nenhuma variável extra (se não passar, ele cria o usuário `admin` e salva uma senha gerada em `/opt/element-call/secrets.yml` no servidor).

Se quiser definir seu próprio usuário e senha, basta passar no comando (ou colocar no `hosts.ini` / `vars.yml`):

| Variável | Padrão | Descrição |
|---|---|---|
| `element_call_user` | `admin` | Usuário inicial criado automaticamente no Synapse (`@usuario:call.<domain>`). |
| `element_call_password` | *(gerado 20 chars em `/opt/element-call/secrets.yml`)* | Senha do usuário inicial. |
| `element_call_allow_guest` | `false` | Se `false`, exige login em `/login`. Se `true`, permite que convidados com o link entrem digitando apenas o nome. |
| `element_call_node_ip` | `vpn_routed_public_ip` ou `ansible_host` | IP público anunciado pelo LiveKit SFU para o tráfego de vídeo/áudio WebRTC. |

---

## 🚀 Como fazer Deploy (Oracle ou Acerola)

1. Crie o registro DNS `A` para `call.<domain>` apontando para o IP público do servidor (modo **DNS only** na Cloudflare).
2. *(Apenas na Oracle Cloud)* Certifique-se de liberar no painel da VCN da Oracle as portas de mídia WebRTC: **`7881/tcp`** e **`50100-50200/udp`** (no firewall interno da VM o Ansible já abre sozinho).

### Via Terminal (Ansible local):
```bash
# Servidor Oracle (definindo seu usuário e senha)
ansible-playbook -i configuration/servers/oracle/hosts.ini configuration/ansible/deploy.yml \
  -e @configuration/servers/oracle/vars.yml \
  -e "element_call_user=vinicius element_call_password=SUA_SENHA_AQUI" \
  --tags element-call

# Servidor Acerola (definindo seu usuário e senha)
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml \
  -e "element_call_user=vinicius element_call_password=SUA_SENHA_AQUI" \
  --tags element-call
```

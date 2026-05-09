# Server Setup Guide

## Table of Contents

- [Pré-requisitos Locais](#pré-requisitos-locais)
- [Configurar Inventário](#configurar-inventário)
- [Gerar Segredos do Authelia](#gerar-segredos-do-authelia)
- [Gerar Hash de Senha](#gerar-hash-de-senha)
- [Executar o Playbook](#executar-o-playbook)

---

## Pré-requisitos Locais

```bash
# Instalar Ansible
pip install ansible

# Verificar conexão com o servidor
ansible -i ansible/hosts.ini relay_servers -m ping
```

---

## Configurar Inventário

Edite o arquivo `ansible/hosts.ini` preenchendo as variáveis do servidor:

```ini
[relay_servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  email=SEU_EMAIL \
  domain=SEU_DOMINIO \
  authelia_jwt_secret=GERE_ABAIXO \
  authelia_session_secret=GERE_ABAIXO \
  authelia_encryption_key=GERE_ABAIXO \
  authelia_user=admin \
  authelia_display_name=Administrador \
  authelia_password_hash=GERE_ABAIXO
```

---

## Gerar Segredos do Authelia

```bash
# jwt_secret
openssl rand -hex 32

# session_secret
openssl rand -hex 32

# encryption_key (precisa de exatamente 32 chars)
openssl rand -hex 16
```

Cole cada valor na variável correspondente do `hosts.ini`.

---

## Gerar Hash de Senha

```bash
docker run --rm authelia/authelia:latest \
  authelia crypto hash generate argon2 --password SUA_SENHA
```

Cole o hash gerado em `authelia_password_hash` no `hosts.ini`.

---

## Executar o Playbook

```bash
ansible-playbook -i ansible/hosts.ini ansible/setup_server.yml
```

O playbook provisiona automaticamente:

- **Docker** + plugins e repositório oficial
- **Firewalld** com portas `80/tcp`, `443/tcp`, `443/udp`, `7824/udp`
- **Rede Docker** `proxy` compartilhada entre os containers
- **Portainer** em `container.DOMINIO`
- **Authelia** em `auth.DOMINIO`
- **Netdata** em `monitor.DOMINIO` (protegido pelo Authelia)
- **Caddy** como proxy reverso com TLS automático

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

Edite o arquivo `inventory.ini` (ou cadastre no GitHub Secrets como `ACEROLA_ANSIBLE_HOSTS_INI` / `ANSIBLE_HOSTS_INI` no Environment `acerola`):

```ini
[servers]
178.105.95.169 ansible_user=root ansible_ssh_forward_agent=true \
  domain=acerola.app \
  email=contact@acerola.app \
  beszel_key="ssh-ed25519 CHAVE_PUBLICA_DO_HUB_ORACLE" \
  netbird_setup_key="SETUP_KEY_GERADA_NO_NETBIRD_ORACLE" \
  netbird_mgmt_url=https://netbird.SEU_DOMINIO_ORACLE.com
```

---

## Executar o Playbook

```bash
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml
```

O playbook provisiona automaticamente:

- **Docker** + plugins e repositório oficial
- **Firewalld** com portas `80/tcp`, `443/tcp`, `443/udp`, `7824/udp`
- **Rede Docker** `proxy` compartilhada entre os containers
- **Portainer Agent** (porta 9001) para gerenciamento centralizado via Oracle
- **Beszel Agent** para envio de métricas ao Beszel Hub (Oracle)
- **NetBird Client** conectado à malha Zero Trust do Oracle
- **Caddy** como proxy reverso com TLS automático

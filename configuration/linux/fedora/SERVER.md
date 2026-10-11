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

Edite o arquivo `ansible/hosts.ini` (ou cadastre no GitHub Secrets como `FEDORA_HOSTS_INI`):

```ini
[relay_servers]
IP_DO_SERVIDOR ansible_user=root ansible_ssh_forward_agent=true \
  email=SEU_EMAIL \
  domain=SEU_DOMINIO \
  beszel_key=CHAVE_PUBLICA_GERADA_PELO_HUB \
  wg_password=SUA_SENHA_DO_PAINEL_VPN
```

---

## Executar o Playbook

```bash
ansible-playbook -i ansible/hosts.ini ansible/setup_server.yml
```

O playbook provisiona automaticamente:

- **Docker** + plugins e repositório oficial
- **Firewalld** com portas `80/tcp`, `443/tcp`, `443/udp`, `51820/udp`, `7824/udp`
- **Rede Docker** `proxy` compartilhada entre os containers
- **Portainer** em `container.DOMINIO`
- **Beszel Agent** para monitoramento do servidor
- **Cockpit** (apenas Rocky Linux) em `cockpit.DOMINIO`
- **WireGuard (wg-easy)** em `vpn.DOMINIO` (com Web UI e QR Code)
- **Caddy** como proxy reverso com TLS automático

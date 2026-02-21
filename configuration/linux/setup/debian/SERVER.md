# Server Setup Guide

## Table of Contents

- [Docker](#docker)
- [Easy Panel](#easy-panel)
- [Nginx](#nginx)
- [Git + SSH Key](#git--ssh-key)
- [File Transfer via SCP](#file-transfer-via-scp)

---

## Docker

```bash
# Instalar pré-requisitos
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Criar keyring do Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Adicionar o repositório Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualizar e instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## Easy Panel

```bash
docker run --rm -it \
  -v /etc/easypanel:/etc/easypanel \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  easypanel/easypanel setup
```

---

## Nginx

```bash
# Instalar pré-requisitos
sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring

# Importar a chave de assinatura oficial do Nginx
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Verificar se o arquivo baixado contém a chave correta
gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

# Adicionar o repositório
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/debian $(lsb_release -cs) nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

# Instalar o Nginx
sudo apt update
sudo apt install nginx

# Habilitar e iniciar o serviço
systemctl enable nginx
systemctl start nginx
```

---

## Git + SSH Key

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "vinicius@email.com"

# Exibir a chave pública
cat ~/.ssh/<nome-da-chave>.pub
```

> Copie o conteúdo exibido e adicione-o nas configurações de SSH do GitHub.

---

## File Transfer via SCP

```bash
scp /caminho/do/arquivo usuario@ip_da_vm:/caminho/de/destino
```
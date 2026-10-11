# Servidor Oracle

Configurações e inventário do servidor Oracle.

## Inventário

Edite o arquivo `inventory.ini` ou cadastre a secret `ORACLE_ANSIBLE_HOSTS_INI` (ou `ANSIBLE_HOSTS_INI` no Environment `oracle`):

```ini
[servers]
IP_DO_SERVIDOR_ORACLE ansible_user=ubuntu ansible_become=true ansible_ssh_forward_agent=true \
  domain=seusite.com \
  email=seu_email@dominio.com
```

## Deploy via GitHub Actions

Na aba **Actions** > **Server Deploy**:
- **Servidor:** `oracle`
- **App:** selecione o serviço desejado ou `all`

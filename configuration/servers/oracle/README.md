# Servidor Oracle

Configurações e inventário do servidor Oracle.

## Inventário

Edite o arquivo `inventory.ini` ou cadastre a secret `ORACLE_ANSIBLE_HOSTS_INI` (ou `ANSIBLE_HOSTS_INI` no Environment `oracle`):

```ini
[servers]
IP_DO_SERVIDOR_ORACLE ansible_user=root ansible_ssh_forward_agent=true email=seu_email@dominio.com domain=seu-dominio.com beszel_key=CHAVE_PUBLICA_GERADA_PELO_HUB
```

## Deploy via GitHub Actions

Na aba **Actions** > **Server Deploy**:
- **Servidor:** `oracle`
- **App:** selecione o serviço desejado ou `all`

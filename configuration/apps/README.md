# Nextcloud + ONLYOFFICE — Setup & Troubleshooting

## Arquitetura

```
Internet → Cloudflare → Nginx (host) → Authelia (9091) → Nextcloud (K3s NodePort 30091)
                                      → ONLYOFFICE (Podman 8080)
```

- **Nextcloud**: Kubernetes (K3s), namespace `nextcloud`, NodePort `30091`
- **ONLYOFFICE**: Podman, porta `8080`, exposto via Nginx em `office.vinicius-gpl.com`
- **Authelia**: Autenticação reversa em `auth.vinicius-gpl.com`
- **Cloudflare**: Proxy ativo (nuvem laranja) para ambos os domínios

---

## Problemas resolvidos e soluções

### 1. X-Frame-Options: SAMEORIGIN bloqueando o iframe do ONLYOFFICE

**Causa**: O Nextcloud injeta `X-Frame-Options: SAMEORIGIN` em todas as respostas. O nginx não removia o header antes de repassar ao cliente.

**Fix** — `/etc/nginx/conf.d/nextcloud.conf`:

```nginx
location / {
    proxy_hide_header X-Frame-Options;
    # demais diretivas...
}
```

**Fix** — `/etc/nginx/conf.d/onlyoffice.conf`:

```nginx
location / {
    proxy_hide_header X-Frame-Options;
    proxy_set_header X-Forwarded-Proto https;
    proxy_redirect http:// https://;
    add_header Content-Security-Policy "frame-ancestors https://nextcloud.vinicius-gpl.com" always;
    add_header Cross-Origin-Resource-Policy "cross-origin" always;
    add_header Cross-Origin-Embedder-Policy "unsafe-none" always;
    # demais diretivas...
}
```

---

### 2. ERR_BLOCKED_BY_RESPONSE no iframe do ONLYOFFICE

**Causa**: Chrome bloqueando por ausência de headers CORP/COEP.

**Fix** — adicionar no `location /` do `onlyoffice.conf`:

```nginx
add_header Cross-Origin-Resource-Policy "cross-origin" always;
add_header Cross-Origin-Embedder-Policy "unsafe-none" always;
```

---

### 3. ONLYOFFICE não conseguia salvar documentos (callback falhou)

**Causa**: O `StorageUrl` nas configurações do ONLYOFFICE apontava para `http://192.168.0.200:8080` (o próprio ONLYOFFICE) em vez do Nextcloud. Além disso, o container Podman (`10.89.x.x`) não roteia para o NodePort do K3s (`192.168.0.200:30091`).

**Fix**: Usar o ClusterIP interno do K3s, que é acessível da rede Podman:

```bash
kubectl exec -n nextcloud <pod> -- php occ config:app:set onlyoffice StorageUrl --value="http://10.43.212.101/"
```

> **Atenção**: a barra `/` no final é obrigatória. Sem ela a URL fica malformada (`http://10.43.212.101apps/...`).

**Fix permanente** — `nextcloud-k3s.yaml`:

```yaml
- name: NEXTCLOUD_TRUSTED_DOMAINS
  value: "nextcloud.vinicius-gpl.com 10.43.212.101"
```

---

### 4. ONLYOFFICE recebia 403 ao baixar arquivos (Authelia bloqueando)

**Causa**: O ONLYOFFICE faz requisições server-to-server para `/apps/onlyoffice/download` e `/apps/onlyoffice/track`, rotas não presentes no bypass do Authelia.

**Fix** — `~/.config/authelia/authelia/configuration.yml`:

```yaml
- domain: nextcloud.vinicius-gpl.com
  resources:
    - "^/status.php$"
    - "^/remote.php/.*$"
    - "^/cron.php$"
    - "^/ocs/.*$"
    - "^/apps/onlyoffice/.*$"
    - "^/index.php/apps/onlyoffice/.*$"
  policy: bypass
```

---

### 5. ONLYOFFICE recebia 400 ao baixar arquivos (trusted_domains)

**Causa**: O Nextcloud rejeita requisições cujo header `Host` não está na lista de trusted domains. O ONLYOFFICE acessa via `10.43.212.101` (ClusterIP), que não estava na lista.

**Fix** — `occ`:

```bash
kubectl exec -n nextcloud <pod> -- php occ config:system:set trusted_domains 2 --value="10.43.212.101"
```

**Fix permanente** — `nextcloud-k3s.yaml`:

```yaml
- name: NEXTCLOUD_TRUSTED_DOMAINS
  value: "nextcloud.vinicius-gpl.com 10.43.212.101"
```

Após editar, aplicar:

```bash
kubectl apply -f nextcloud-k3s.yaml
```

---

## Configurações finais relevantes

### StorageUrl (ONLYOFFICE → Nextcloud, interno)

```bash
kubectl exec -n nextcloud <pod> -- php occ config:app:get onlyoffice StorageUrl
# http://10.43.212.101/
```

### DocumentServerUrl (Nextcloud → ONLYOFFICE, público)

```
https://office.vinicius-gpl.com/
```

### Rede

| Origem              | Destino                   | IP/Porta              | Status        |
| ------------------- | ------------------------- | --------------------- | ------------- |
| Podman (ONLYOFFICE) | K3s ClusterIP (Nextcloud) | `10.43.212.101:80`    | ✅ funciona   |
| Podman (ONLYOFFICE) | NodePort host             | `192.168.0.200:30091` | ❌ não roteia |
| Podman (ONLYOFFICE) | Gateway Podman            | `10.89.1.1:30091`     | ❌ não roteia |

---

## Comandos úteis

```bash
# Ver logs do ONLYOFFICE
podman logs onlyoffice --tail 50 | grep -i "error\|callback\|download"

# Verificar configurações do plugin ONLYOFFICE no Nextcloud
kubectl exec -n nextcloud <pod> -- php occ config:app:list onlyoffice

# Testar conectividade ONLYOFFICE → Nextcloud
podman exec onlyoffice curl -I http://10.43.212.101/status.php

# Recarregar nginx
nginx -t && systemctl reload nginx

# Verificar headers de resposta
curl -IL https://office.vinicius-gpl.com/ 2>&1 | grep -i "x-frame\|cross-origin\|content-security"
```

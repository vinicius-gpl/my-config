# Stack de Monitoramento: Prometheus + Grafana + Node Exporter + cAdvisor

Esta stack provê monitoramento detalhado de recursos de hardware e containers Docker.

---

## 📦 Componentes

1. **Prometheus (`prom/prometheus:v2.51.0`)**: Coleta e armazena séries temporais com retenção configurada para 15 dias (ou máximo de 5 GB).
2. **Node Exporter (`prom/node-exporter:v1.7.0`)**: Coleta métricas de hardware e SO (CPU, RAM, Disco, IO, Rede, Load Average).
3. **cAdvisor (`gcr.io/cadvisor/cadvisor:v0.49.1`)**: Coleta métricas de uso de recursos específicas de cada container Docker.
4. **Grafana (`grafana/grafana:10.4.1`)**: Painéis e dashboards visuais com o Prometheus já pré-configurado como fonte de dados padrão.

---

## 🚀 Como subir via Ansible

Por padrão, a stack só é implantada quando você passar a tag explicitamente (para evitar consumo acidental de RAM em servidores com pouca memória):

```bash
# Deploy no servidor alvo (ex: acerola ou oracle)
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml --tags "monitoring"

# Ou passar a flag via extra-vars:
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/deploy.yml -e "monitoring_enabled=true"
```

---

## 🧹 Como remover via Ansible

```bash
# Parar e remover containers
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/clean.yml --tags "monitoring"

# Remover também os volumes de dados persistentes:
ansible-playbook -i configuration/servers/acerola/inventory.ini configuration/ansible/clean.yml --tags "monitoring" -e "remove_volumes=true"
```

---

## 📊 Dashboards recomendados para importar no Grafana

Após acessar o Grafana (porta `3000` ou `grafana.seu-dominio.com`):
1. Faça login com usuário `admin` (senha gerada no `.env` do servidor ou definida em `grafana_admin_password`).
2. Vá em **Dashboards > New > Import**.
3. Importe os seguintes IDs da comunidade:
   - **`1860`** — *Node Exporter Full* (o dashboard mais completo para métricas de host/SO).
   - **`14282`** ou **`10619`** — *Docker & cAdvisor* (monitoramento detalhado de containers Docker).

---

## 🌐 Acesso via Caddy

Se o servidor rodar Caddy com o snippet `vpn_only`, o arquivo `config/grafana.caddy` publica o serviço em `grafana.<seu_dominio>` acessível apenas por peers conectados à VPN NetBird/WireGuard.

# Rocky Linux

Mesmo padrão do `fedora/`, trocando Caddy + Portainer por **Coolify** e
somando **Supabase**. Beszel e Cockpit são idênticos ao fedora.

```
ansible/
├─ inventory.ini      modelo; copie para hosts.ini (ignorado pelo git)
├─ setup_server.yml   tags: base, coolify, supabase, beszel, cockpit
└─ templates/         coolify.env.j2, supabase.env.j2, cockpit.conf.j2
```

Os `compose.yml` ficam em `configuration/linux/global/docker/{coolify,supabase}/`,
como os dos outros serviços.

```bash
cd configuration/linux/rocky/ansible
cp inventory.ini hosts.ini          # e preencha
ansible-playbook -i hosts.ini setup_server.yml
ansible-playbook -i hosts.ini setup_server.yml --tags supabase
```

Ou pelo Actions: **Rocky/Ansible** → *Run workflow*. Secrets usados:
`SSH_PRIVATE_KEY`, `SSH_PASSPHRASE` (se houver), `ANSIBLE_ROCKY_HOSTS_INI`,
`ANSIBLE_BECOME_PASSWORD`.

---

## Portas

| Porta | Serviço | Firewall |
|---|---|---|
| 80, 443, 443/udp | traefik do Coolify | aberto |
| 45876 | agente do Beszel | aberto |
| 8080 | dashboard do traefik do Coolify | fechado — não use |
| 8000 | painel do Coolify | fechado |
| 6001, 6002 | websocket e terminal web do Coolify | fechado |
| 8001, 8444 | Kong do Supabase | fechado |
| 5432 | Postgres do Supabase | fechado |
| 9090 | Cockpit | fechado |

"Fechado" = publicado pelo Docker mas sem regra no firewalld, igual ao
Portainer no `fedora/`. Chegue neles por túnel —

```bash
ssh -L 8000:127.0.0.1:8000 -L 8001:127.0.0.1:8001 root@servidor
```

— ou publique num domínio criando o serviço no painel do Coolify, apontando
para `host.docker.internal:<porta>`. É assim que `cockpit.{{ domain }}` e
`supabase.{{ domain }}` entram, já que não há mais Caddy com `conf.d`.

**O painel do Coolify fica na 8000, não na 8080.** O compose que o Coolify gera
para o traefik publica 80, 443, 443/udp **e 8080** (o dashboard dele). Os dois
na mesma porta e o proxy nem sobe: `Bind for 0.0.0.0:8080 failed: port is
already allocated` — e pior, ele fica `Up` sem rede e sem porta alguma, 80 e
443 incluídas. A 8000 é o default oficial do painel. Por isso o **Kong do
Supabase foi para a 8001**.

---

## Segredos

Todos vêm do inventário, como `beszel_key` no `fedora/`. O `inventory.ini` tem
os comandos `openssl` para gerar cada um, e o trecho para gerar `anon_key` e
`service_role_key` a partir do `supabase_jwt_secret`.

Três que não dá para trocar depois:

- **`coolify_app_key`** — é a chave com que o Laravel cifra o banco do Coolify,
  chaves SSH dos servidores inclusive. Trocar depois do primeiro boot = ele não
  decifra mais nada.
- **`supabase_postgres_password`** — gravada nas roles na criação do volume.
  Trocar exige `down -v`, que apaga o banco.
- **`supabase_jwt_secret`** — `anon_key` e `service_role_key` são assinadas com
  ele, e ele é gravado no banco pelo `config/db/jwt.sql` no primeiro boot.

E duas regras do Coolify que não são opcionais: o domínio de
`coolify_root_email` precisa resolver em DNS (nada de `.local`) e
`coolify_root_password` precisa ter maiúscula, minúscula, número, símbolo e não
aparecer em vazamentos conhecidos. Fora disso o seeder não cria o usuário e não
há como entrar no painel.

---

## O que mudou vindo do `~/Desktop/compose`

**Supabase** — sem credencial no arquivo (tudo via `.env`); `container_name` e
`TENANT_ID` de `testlab-*` para `supabase-*`, com o realtime virando
`realtime-dev.supabase-realtime` (o ponto é exigência do cluster Erlang) e as
duas URLs correspondentes no `kong.yml` acompanhando; `./volumes/` virou
`./config/`; CORS e SMTP viraram variável; signup e `verify_jwt` fechados.

**Coolify** — saíram dois serviços:

- `coolify-init`: o preparo de `/data/coolify` (mkdir, `ssh-keygen`,
  `chown 9999:root`) virou tarefa do Ansible. Mesmo preparo do `install.sh`
  oficial, e pelo mesmo motivo: o `ProductionSeeder` procura um arquivo com
  `@host.docker.internal` em `storage/app/ssh/keys` no primeiro boot e só então
  cria a private key `id=0`, que é a que o servidor `localhost` referencia. Sem
  ela no lugar, a UI devolve 500 com *"Call to a member function getPublicKey()
  on null"*.
- `coolify-host`: só existia porque o Windows não tem sshd no host. Aqui o host
  *é* Linux, então o Coolify entra por SSH no próprio servidor
  (`host.docker.internal` → `host-gateway`) e o playbook põe a chave pública no
  `authorized_keys` do root — o caminho do instalador oficial.

E `/data/coolify` virou bind mount em vez de volume nomeado, também como no
instalador oficial: o Coolify escreve ali os compose das apps e do proxy, e quem
resolve os bind mounts desses compose é o **daemon do host**.

---

## Notas

- `supabase_profiles=extras` liga `realtime`, `imgproxy` e `functions` —
  10 containers em vez de 7.
- Os scripts em `config/db/` só rodam na criação do volume. Mudou um SQL?
  `down -v` e suba de novo (apaga o banco).
- O playbook não instala WireGuard; está fora do escopo dele.
- SELinux: o Docker CE não rotula bind mounts por padrão, então
  `/opt/supabase/config` e `/data/coolify` montam como estão. Se ligar
  `selinux-enabled` no `daemon.json`, esses mounts vão precisar de `:z`.

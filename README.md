# Minha configuração de sistemas, programas e containers

- Todos projetos que eu uso estão sendo referenciados no projeto.

## Windows

[Raiz](1.my-config/1-WINDOWS/)

- Script para instalação de programas padrões
[Scripts](1.my-config/1-WINDOWS/1.script-install-winget-apps/)

  - Arquivo para ser executado e abrir um terminal winget
    [winget](1.my-config/1-WINDOWS/1.script-install-winget-apps/install.winget)

  - Arquivo para abrir uma interface e selecionar programas para ser instalados via winget
    [script winget](1.my-config/1-WINDOWS/1.script-install-winget-apps/apps-install/apps.cmd)

- Script para gerar uma .iso com arquivos dentro, por exemplo o autounattend.xml
[script](1.my-config/1-WINDOWS/2.windows-11-generate-file-iso/GENERATE-ISO.cmd)

## Linux

[Raiz](1.my-config/2-LINUX/1.grub/)

- Script para instalar tema, o tema foi modificado as imagens, os originais são do repositório [Elegant-grub2-themes](Elegant-grub2-themes/)
[Script](1.my-config/2-LINUX/1.grub/1.themes/install.sh)

- Arquivos de configuração de ambiente
[Raiz](1.my-config/2-LINUX/2.services/)

  - Script para organizar arquivos que corrigem erros ao conectar meu fone, o erro é relacionado ao alsa que abaixa os canais de audio do fone quando conecto
    [Script](1.my-config/2-LINUX/2.services/1.headeset-service/setup.sh)

  - Tema catppuccin para o kitty [Catppuccin](kitty/) é só copiar para ~/.config/kitty
    [Arquivos](1.my-config/2-LINUX/2.services/2.kitty/)

  - Tema para neofetch [Neofetch themes](neofetch-themes/) é só copiar para ~/.config/neofetch
    [Arquivos](1.my-config/2-LINUX/2.services/3.neofetch-themes/)

  - Versões de programas do asdf que geralmente uso
    [Script](1.my-config/2-LINUX/2.services/4.asdf/asdf.sh)

## Container

[Raiz](1.my-config/3-CONTAINER/)

- Portainer + Portainer docker agent
[yml](1.my-config/3-CONTAINER/1.portainer/portainer-docker-compose.yml)

```cmd
docker compose -f portainer-docker-compose.yml -p portainer up -d
```

- Meus gerenciadores de DNS/DNS recursivos

  - Pihole + unbound [Pihole](docker-pi-hole/) [Unbound](unbound-docker/)
  [yml](1.my-config/3-CONTAINER/2.dns/1.pi-hole/dns-docker-compose.yml)

  ```cmd
  docker compose -f dns-docker-compose.yml -p dns up -d
  ```

  - AdGuard [AdGuard Home](AdGuardHome/)
  [yml](1.my-config/3-CONTAINER/2.dns/2.adguard-home/dns-docker-compose.yml)

  ```cmd
  docker compose -f dns-docker-compose.yml -p dns up -d
  ```

- Ambiente de 🏴‍☠️

  - Transmission docker [Transmission](docker-transmission/)
  [yml](1.my-config/3-CONTAINER/3.midia/1.transmission-utorrent/transmission-docker-compose.yml)

  ```cmd
    docker compose -f transmission-docker-compose.yml -p transmission up -d
  ```

  - Stremio [Stremio](stremio-docker/)
  [yml](1.my-config/3-CONTAINER/3.midia/2.stremio-media-streaming/stremio-docker-compose.yml)

  ```cmd
    docker compose -f stremio-docker-compose.yml -p stremio up -d
  ```

  - Kaizoku + redis + kavita + postgresql [Kaizoku](kaizoku/) [Kavita](Kavita/) o projeto serve para baixar mangás e criar um ambiente de leitura
  [yml](1.my-config/3-CONTAINER/3.midia/3.kaizoku-manga-reader/kaizoku-docker-compose.yml)

  ```cmd
    docker compose -f kaizoku-docker-compose.yml -p kaizoku up -d
  ```

# Verifique arquivos .env e os volumes dos containers!
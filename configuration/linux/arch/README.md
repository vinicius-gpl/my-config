# Arch Linux — desktop Hyprland

Não existia nada de Arch no repositório: os dotfiles de
`configuration/linux/global/.config/.dotfiles` estavam versionados, mas nada
instalava os programas que eles chamam nem linkava as configs. É o que este
playbook faz.

Diferente do `fedora/` e do `rocky/`, que provisionam servidor por SSH, aqui é
a **própria máquina**: os dotfiles entram por symlink apontando para o
repositório, então editar no repo vale na hora.

```
ansible/
├─ inventory.ini        localhost, connection=local
└─ setup_desktop.yml    tags: base, yay, pkgs, dotfiles, shell
```

## Rodar

```bash
sudo pacman -S --needed ansible

cd configuration/linux/arch/ansible
sudo -v && ansible-playbook -i inventory.ini setup_desktop.yml -K
```

Um bloco por vez:

```bash
ansible-playbook -i inventory.ini setup_desktop.yml --tags dotfiles
ansible-playbook -i inventory.ini setup_desktop.yml --tags pkgs -K
```

Não há workflow no Actions para este: é máquina local, não tem o que a CI
alcançar.

---

## O `sudo -v` não é enfeite

O `yay` escala privilégios por conta própria — ele chama `sudo pacman` por
dentro. Rodando dentro do Ansible, esse sudo não tem tty, então ou a
credencial já está em cache ou a task falha esperando uma senha que ninguém vai
digitar.

Duas saídas, e a escolha é sua:

1. **`sudo -v` imediatamente antes do playbook.** A credencial fica em cache e
   o `--sudoloop` do yay a mantém viva pelo resto da execução. É o default.
2. **`pacman_nopasswd=true`.** Grava `%wheel ALL=(root) NOPASSWD: /usr/bin/pacman`
   em `/etc/sudoers.d/`, validado com `visudo -cf`. Mais cômodo, menos seguro:
   qualquer um no grupo `wheel` passa a instalar pacote sem senha.

O `-K` do comando é para o `become` do próprio Ansible (as tasks de `pacman`),
que é coisa separada do sudo interno do yay.

---

## pacman ou yay?

`pacman_packages` tem o que vem dos repositórios oficiais; `aur_packages` vai
pelo yay.

A divisão **erra em uma direção só, de propósito**: o yay resolve repositório
oficial também, então um pacote de `aur_packages` que tenha migrado para o
`extra` instala normalmente. O contrário não vale — nome que só existe no AUR
dentro de `pacman_packages` quebra com `target not found`.

Por isso os que mudam de repositório de vez em quando (`swww`, `swaync`,
`ncspot`, `mise`, `zed`, `wezterm`, `bottom`) estão na lista do yay, mesmo que
hoje alguns estejam no `extra`. Se o pacman reclamar de `target not found` em
algum nome, a correção é mover aquele nome para `aur_packages`.

---

## De onde saiu a lista de pacotes

Foi lida dos próprios dotfiles, não escolhida a dedo:

| Origem | O que pediu |
|---|---|
| `hypr/conf/autostart.conf` | `polkit-gnome`, `hypridle`, `caelestia-shell`, `swww`, `pyprland`, `swaync` |
| `hypr/conf/binding.conf` | `kitty`, `thunar`, `google-chrome`, `hyprlock`, `hyprshot`, `wlogout`, `wireplumber` (`wpctl`), `brightnessctl`, `playerctl` |
| `hypr/conf/plugin.conf` | plugin `dynamic-cursors`, via `hyprpm` (ver abaixo) |
| `.bashrc` | `eza`, `starship`, `asciiquarium`, `bottom` (`btm`), `ncspot`, `neovim` |
| `fish/config.fish` | `oh-my-posh`, `fzf`, `bat`, `fastfetch`, `neovim` |
| `mise/config.toml` | `mise` |
| diretórios de `.dotfiles/` | `lazygit`, `wezterm`, `zed` |

Duas coisas do `fish/config.fish` ficaram **de fora** por não serem gerenciáveis
daqui: o `brew shellenv` do Linuxbrew (instalador próprio) e os caminhos de
TeX Live 2025 e Android SDK, que apontam para `/home/vinicius` e para
instalações manuais.

---

## O plugin do Hyprland não entra pelo playbook

O `autostart.conf` carrega
`~/.local/share/hyprpm/dynamic-cursors/dynamic-cursors.so`. O `hyprpm enable` e
o `hyprpm reload` precisam de uma sessão Hyprland **rodando** — não dá para
fazer isso de um playbook que roda antes de você entrar na sessão. Então o
playbook só imprime o comando no final:

```bash
hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors
hyprpm reload -n
```

---

## Notas

- **Suas configs atuais não são sobrescritas em silêncio.** Antes de linkar, o
  que existe em `~/.config/<nome>` e não é symlink é renomeado para
  `<nome>.bak-<epoch>`. O que já é symlink é só substituído.
- **Sem `become: yes` no play inteiro**, diferente do `fedora/` e do `rocky/`:
  o `makepkg` se recusa a rodar como root e os dotfiles precisam ir para o seu
  home, não para `/root`. A escalada é task por task.
- **O yay é instalado em duas etapas** — `makepkg -s` (sem `-i`) como usuário e
  depois `pacman -U` com o become do Ansible. Com `-i` o makepkg chamaria sudo
  sozinho e travaria sem tty, o mesmo problema do yay.
- **`pacman -Syu` roda por padrão.** O Arch não suporta upgrade parcial:
  instalar pacote novo num sistema desatualizado é o caminho curto para quebrar
  biblioteca. `system_upgrade=false` desliga, mas pensando bem antes.
- **O shell de login vira `fish`.** `set_fish_as_shell=false` se não quiser.

#!/bin/bash

ROOT_UID=0
THEME_DIR="/usr/share/grub/themes"
THEME_NAME=frieren-window-left-dark

MAX_DELAY=20

CDEF=" \033[0m"
b_CCIN=" \033[1;36m"
b_CGSC=" \033[1;32m"
b_CRER=" \033[1;31m"
b_CWAR=" \033[1;33m"

# Função de mandar as msg bonitinhas
prompt() {
  case ${1} in
  "-s" | "--success")
    echo -e "${b_CGSC}${*//-s/}${CDEF}"
    ;;
  "-e" | "--error")
    echo -e "${b_CRER}${*//-e/}${CDEF}"
    ;;
  "-w" | "--warning")
    echo -e "${b_CWAR}${*//-w/}${CDEF}"
    ;;
  "-i" | "--info")
    echo -e "${b_CCIN}${*//-i/}${CDEF}"
    ;;
  *)
    echo -e "$@"
    ;;
  esac
}

function has_command() {
  command -v -- "$1 >/dev/null"
}

prompt -w "Verificando se foi executado com root...\n"

if [ "$UID" -eq "$ROOT_UID" ]; then

  # Cria a pasta do thema
  prompt -i "Verificando se a pasta do thema existe...\n"
  [[ -d ${THEME_DIR:?}/${THEME_NAME} ]] && rm -rf "${THEME_DIR:?}/${THEME_NAME}"
  mkdir -p "${THEME_DIR}/${THEME_NAME}"

  # Copia o thema para pasta do grub
  prompt -i "Instalando o thema ${THEME_NAME}...\n"
  cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}

  prompt -i "Coloca o thema no arquivo do grub...\n"
  cp -an /etc/default/grub /etc/default/grub.bak
  grep "GRUB_THEME=" /etc/default/grub >/dev/null 2>&1 && sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >>/etc/default/grub

  # Atualiza a config do grub grub-mkconfig
  prompt -i "Grub config...\n"
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command zypper || has_command transactional-update; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
  elif has_command dnf || has_command rpm-ostree; then

    # Verifica se o EFI do grub tá disponivel no fedora ou demais distros
    # WARN: Fedora tem o grub instalado diferente
    if [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
      prompt -s "Procurando config do grub /boot/efi/EFI/fedora/grub.cfg...\n"
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

    elif [[ -f /boot/grub2/grub.cfg ]]; then
      prompt -s "Procurando config do grub boot/grub2/grub.cfg...\n"
      grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
  fi

  prompt -s "\n Instalado! \n"
else
  prompt -e "[ Error! ] -> Necessário de root "

  read -r -p "[ trusted ] Coloque a senha de root: " -t "${MAX_DELAY}" -s

  if [[ -n "$REPLY" ]]; then
    sudo -S "$0" <<<"$REPLY"
  else
    prompt "Cancelado"
    exit 1
  fi

fi

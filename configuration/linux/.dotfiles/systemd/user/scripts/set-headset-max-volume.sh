#!/bin/bash

echo "[INFO] Aguardando dispositivos de áudio..."

MAX_TRIES=10
for i in $(seq 1 $MAX_TRIES); do
  # Espera o dispositivo Fuxi-H3 ser detectado
  card_number=$(arecord -l | grep -i 'Fuxi-H3' | awk '{print $2}' | sed 's/[^0-9]*//g')

  if [ -n "$card_number" ]; then
    echo "[INFO] Dispositivo Fuxi-H3 encontrado no card $card_number."
    break
  fi

  echo "[WARN] Dispositivo não encontrado, tentativa $i de $MAX_TRIES..."
  sleep 1
done

if [ -z "$card_number" ]; then
  echo "[ERRO] Dispositivo Fuxi-H3 não encontrado após $MAX_TRIES tentativas."
  exit 1
fi

# Verifica se o PulseAudio está rodando e inicia caso não esteja
if ! pactl info &>/dev/null; then
  echo "[INFO] PulseAudio não está em execução. Tentando iniciar..."
  pulseaudio --start
  sleep 1
fi

# Define volume usando pactl
echo "[INFO] Ajustando volumes..."
pactl set-sink-volume @DEFAULT_SINK@ 100%

# Ajusta volumes do dispositivo usando amixer
amixer -c $card_number sset 'PCM',0 100% unmute
amixer -c $card_number sset 'PCM',1 100% unmute
amixer -c $card_number sset 'Mic',0 100% unmute
amixer -c $card_number sset 'Mic',1 100% unmute

echo "[OK] Configuração concluída para o Fuxi-H3!"
exit 0
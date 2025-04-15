#!/bin/bash
sleep 5

# Define o volume principal como 100%
pactl set-sink-volume @DEFAULT_SINK@ 100%

# Encontrar o número do card
card_number=$(arecord -l | grep -i 'Fuxi-H3' | awk '{print $2}' | sed 's/://')

if [ -z "$card_number" ]; then
  echo "Dispositivo Fuxi-H3 não encontrado!"
  exit 0
fi

echo "Configurando o volume para o Fuxi-H3 no card $card_number..."

amixer -c $card_number sset 'PCM',0 100% unmute
amixer -c $card_number sset 'PCM',1 100% unmute
amixer -c $card_number sset 'Mic',0 100% unmute
amixer -c $card_number sset 'Mic',1 100% unmute

echo "Configuração concluída para o Fuxi-H3!"
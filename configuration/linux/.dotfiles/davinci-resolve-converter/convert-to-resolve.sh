#!/usr/bin/env bash
# Website:     https://4fasters.com.br
# Autor:       Mateus Gabriel Müller
# Créditos:    
#
# Os créditos vão todos para o Henrique da equipe do Diolinux que lançou a ideia, e eu só
# reescrevi para aderir a minha necessidade.
# >>>> https://www.diolinux.com.br/2019/02/codecs-certos-no-davinci-resolve.html <<<<
#
# -------------------------------EXECUÇÃO----------------------------------------- #
# Minha verão forma de fazer com um arquivo só
#
#  ./convert-to-resolve.sh video.mp4 e ele criar o .mov no mesmo diretório com o _resolve.mov se executar de novo ele substitui
#
#
#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <caminho/do/arquivo>"
    exit 1
fi

file=$(realpath "$1" 2>/dev/null)

if [ ! -e "$file" ]; then
    echo "Arquivo não encontrado: $1"
    exit 1
fi

dir=$(dirname "$file")
file_name=$(basename "$file")
echo "Nome do arquivo: $file_name"

for converter in $(find "$file_name" -type f \( -iname \*.mov \
                                          -o -iname \*.mp4 \
                                          -o -iname \*.mkv \
                                          -o -iname \*.webm \) \
                                          -printf "%h\n" | sort | uniq)
do 
    echo "Converter: $converter"

    find "$converter" -type f \( -iname \*.mov -o -iname \*.mp4 -o -iname \*.mkv -o -iname \*.webm \) -print0 |
    while IFS= read -r -d '' arquivo; do
	echo "Arquivo: $arquivo"

        if [ "$arquivo" == "./$file_name" ]; then
            echo "Arquivo encontrado: $arquivo"
            ffmpeg -y -i "$converter/$arquivo" \
                   -codec:v mpeg4 \
                   -q:v 0 \
                   -codec:a pcm_s16le \
                   -max_muxing_queue_size 9999 \
                   "$converter/${arquivo%.*}_resolve.mov"
        fi
    done
done


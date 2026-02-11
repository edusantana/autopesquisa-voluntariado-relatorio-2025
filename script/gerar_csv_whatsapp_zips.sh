#!/usr/bin/env bash
# gerar_csv_whatsapp_zips.sh
#
# Gera um CSV (IC, Nome do Arquivo, Tamanho em KB) a partir de arquivos .zip
# em uma árvore de diretórios (recursivo).
#
# Regras:
# - "IC" = primeiro diretório abaixo de "." (ex.: ./ISIC/arquivo.zip -> ISIC)
# - "Nome do Arquivo" = nome do arquivo sem caminho, removendo prefixos:
#     - "Conversa do WhatsApp com "
#     - "WhatsApp Chat with "
# - "Tamanho em KB" = arredondado para cima (ceil(bytes/1024))
#
# Uso:
#   cd /caminho/para/Todos
#   ./gerar_csv_whatsapp_zips.sh > arquivos_zip.csv
#
# Dependências:
# - find
# - awk
# - stat (GNU coreutils)  -> no Ubuntu/WSL ok

set -euo pipefail

find . -type f -name '*.zip' -print0 \
| awk -v RS='\0' -F/ '
  BEGIN {
    OFS=",";
    print "IC,Nome do Arquivo,Tamanho em KB"
  }
  {
    path = $0

    # IC = primeiro diretório abaixo de "."
    ic = ($2 == "" ? "." : $2)

    # Nome do arquivo (último segmento do caminho)
    file = $NF

    # Remove prefixos do WhatsApp no nome do arquivo
    sub(/^Conversa do WhatsApp com[ ]+/, "", file)
    sub(/^WhatsApp Chat with[ ]+/, "", file)

    # Tamanho em bytes (stat GNU)
    cmd = "stat -c %s " "\"" path "\""
    cmd | getline bytes
    close(cmd)

    # bytes -> KB (arredonda para cima)
    kb = int((bytes + 1023) / 1024)

    # Escapa aspas duplas para CSV
    gsub(/"/, "\"\"", file)
    gsub(/"/, "\"\"", ic)

    print "\"" ic "\"" "," "\"" file "\"" "," kb
  }
'

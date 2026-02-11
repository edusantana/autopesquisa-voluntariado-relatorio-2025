find . -type f -name '*.zip' -print0 \
| awk -v RS='\0' -F/ '
  BEGIN { OFS=","; print "IC,Nome do Arquivo,Tamanho em KB" }
  {
    path=$0
    ic = ($2=="" ? "." : $2)
    file = $NF

    cmd = "stat -c %s " "\"" path "\""
    cmd | getline bytes
    close(cmd)

    kb = int((bytes + 1023) / 1024)

    gsub(/"/, "\"\"", file)
    gsub(/"/, "\"\"", ic)

    print "\"" ic "\"" "," "\"" file "\"" "," kb
  }
' > arquivos_zip.csv

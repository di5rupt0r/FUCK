#!/bin/bash

# --- Validação de Entrada ---
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <caminho_da_wordlist> <arquivo_de_saida.csv>"
    exit 1
fi

WORDLIST=$1
OUTPUT_FILE=$2

# Verifica se a wordlist existe
if [ ! -f "$WORDLIST" ]; then
    echo "Erro: Arquivo de wordlist '$WORDLIST' não encontrado."
    exit 1
fi

# --- Início do Processo ---
echo "Iniciando a geração de hashes a partir de '$WORDLIST'..."
echo "Salvando em '$OUTPUT_FILE'..."

# Escreve o cabeçalho no arquivo de saída com todos os hashes solicitados
echo "senha:md5:sha1:sha224:sha256:sha384:sha512" > "$OUTPUT_FILE"

# Prepara um contador para feedback
COUNT=0

# Lê a wordlist linha por linha de forma eficiente
while IFS= read -r senha || [[ -n "$senha" ]]; do
    # Ignora linhas em branco
    if [ -z "$senha" ]; then
        continue
    fi

    # Calcula todos os hashes. O comando 'tr -d' remove o lixo da saída dos comandos *-sum
    HASH_MD5=$(echo -n "$senha" | md5sum | tr -d '  -')
    HASH_SHA1=$(echo -n "$senha" | sha1sum | tr -d '  -')
    HASH_SHA224=$(echo -n "$senha" | sha224sum | tr -d '  -')
    HASH_SHA256=$(echo -n "$senha" | sha256sum | tr -d '  -')
    HASH_SHA384=$(echo -n "$senha" | sha384sum | tr -d '  -')
    HASH_SHA512=$(echo -n "$senha" | sha512sum | tr -d '  -')

    # Monta a linha e anexa ao arquivo de saída na ordem correta
    echo "${senha}:${HASH_MD5}:${HASH_SHA1}:${HASH_SHA224}:${HASH_SHA256}:${HASH_SHA384}:${HASH_SHA512}" >> "$OUTPUT_FILE"

    # Fornece feedback a cada 100.000 senhas processadas
    ((COUNT++))
    if ! ((COUNT % 100000)); then
        echo "... $COUNT senhas processadas."
    fi

done < "$WORDLIST"

echo "Processo concluído! Total de $COUNT senhas processadas."
echo "CSV estruturado salvo em '$OUTPUT_FILE'."
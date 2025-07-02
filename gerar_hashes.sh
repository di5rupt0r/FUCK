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

    # --- CORREÇÃO AQUI ---
    senha_clean=$(echo -n "$senha" | tr -d '\r\n')
    HASH_MD5=$(echo -n "$senha_clean" | md5sum | awk '{print $1}')
    HASH_SHA1=$(echo -n "$senha_clean" | sha1sum | awk '{print $1}')
    HASH_SHA224=$(echo -n "$senha_clean" | sha224sum | awk '{print $1}')
    HASH_SHA256=$(echo -n "$senha_clean" | sha256sum | awk '{print $1}')
    HASH_SHA384=$(echo -n "$senha_clean" | sha384sum | awk '{print $1}')
    HASH_SHA512=$(echo -n "$senha_clean" | sha512sum | awk '{print $1}')

    echo "${senha_clean}:${HASH_MD5}:${HASH_SHA1}:${HASH_SHA224}:${HASH_SHA256}:${HASH_SHA384}:${HASH_SHA512}" >> "$OUTPUT_FILE"

    # Fornece feedback a cada 100.000 senhas processadas
    ((COUNT++))
    if ! ((COUNT % 100000)); then
        echo "... $COUNT senhas processadas."
    fi

done < "$WORDLIST"

echo "Processo concluído! Total de $COUNT senhas processadas."
echo "CSV estruturado salvo em '$OUTPUT_FILE'."
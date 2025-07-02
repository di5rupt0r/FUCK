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

# --- Lógica da Barra de Progresso ---
# Pega o número total de linhas para calcular a porcentagem
TOTAL_LINES=$(wc -l < "$WORDLIST" | tr -d ' ')
COUNT=0
WIDTH=50 # Largura da barra de progresso em caracteres

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

    ((COUNT++))
    # Atualiza a barra a cada 1000 linhas para não impactar a performance
    # Ou atualiza uma última vez quando o contador chegar ao final
    if (( COUNT % 1000 == 0 )) || (( COUNT == TOTAL_LINES )); then
        PERCENT=$((COUNT * 100 / TOTAL_LINES))
        FILLED_WIDTH=$((WIDTH * PERCENT / 100))
        EMPTY_WIDTH=$((WIDTH - FILLED_WIDTH))

        # Desenha a barra
        printf "\r["
        printf "%${FILLED_WIDTH}s" "" | tr ' ' '#'
        printf "%${EMPTY_WIDTH}s" ""
        printf "] %d%% (%d/%d)" "$PERCENT" "$COUNT" "$TOTAL_LINES"
    fi

done < "$WORDLIST"

echo "Processo concluído! Total de $COUNT senhas processadas."
echo "CSV estruturado salvo em '$OUTPUT_FILE'."
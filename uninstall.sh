#!/bin/bash

# --- Script para desinstalar a ferramenta 'fuck' e parar seu ambiente Redis ---

# 1. Verificação de Privilégios
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Por favor, execute este script como root ou com sudo."
  exit 1
fi

# 2. Definição de Variáveis
CMD_NAME="fuck"
INSTALL_PATH="/usr/local/bin/${CMD_NAME}"
DOCKER_COMPOSE_PATH="$(pwd)/docker-compose.yml"

echo "Iniciando a desinstalação..."

# 3. Parando e Removendo o Contêiner do Redis
if [ -f "$DOCKER_COMPOSE_PATH" ]; then
    echo "-> Parando e removendo o contêiner do Redis..."
    # 'down --volumes' para o container, remove a rede e também os volumes de dados
    docker-compose down --volumes
else
    echo "AVISO: docker-compose.yml não encontrado. Pulando a etapa do Docker."
fi

# 4. Removendo o Comando
if [ -L "$INSTALL_PATH" ]; then
    echo "-> Removendo o comando '${CMD_NAME}'..."
    rm "$INSTALL_PATH"
else
    echo "AVISO: Comando '${CMD_NAME}' não encontrado em ${INSTALL_PATH}."
fi

echo ""
echo ">>> Desinstalação concluída. <<<"

exit 0
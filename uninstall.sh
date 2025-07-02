#!/bin/bash

# --- Script para desinstalar a ferramenta 'fuck' e seu ambiente ---

# 1. Verificação de Privilégios
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Por favor, execute este script como root ou com sudo."
  exit 1
fi

# 2. Definição de Variáveis
INSTALL_DIR=$(pwd)
VENV_DIR="${INSTALL_DIR}/.venv"
CMD_NAME="fuck"
INSTALL_PATH="/usr/local/bin/${CMD_NAME}"

echo "Iniciando a desinstalação..."

# 3. Removendo o Comando
if [ -f "$INSTALL_PATH" ]; then
    echo "-> Removendo o comando '${CMD_NAME}'..."
    rm "$INSTALL_PATH"
else
    echo "AVISO: Comando '${CMD_NAME}' não encontrado."
fi

# 4. Removendo o Ambiente Virtual
if [ -d "$VENV_DIR" ]; then
    echo "-> Removendo o ambiente virtual..."
    rm -rf "$VENV_DIR"
fi

# 5. Parando o ambiente Docker
if [ -f "${INSTALL_DIR}/docker-compose.yml" ] && command -v docker-compose &> /dev/null; then
    echo "-> Parando e removendo o contêiner do Redis..."
    docker-compose down --volumes
fi

echo ""
echo ">>> Desinstalação concluída. <<<"

exit 0
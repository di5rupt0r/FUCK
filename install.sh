#!/bin/bash

# --- Script para instalar a ferramenta 'fuck' e seu ambiente Redis via Docker ---

# 1. Verificação de Privilégios
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Por favor, execute este script como root ou com sudo."
  echo "Exemplo: sudo bash install.sh"
  exit 1
fi

# 2. Definição de Variáveis
INSTALL_DIR=$(pwd)
MAIN_SCRIPT_PATH="${INSTALL_DIR}/main.py"
REQUIREMENTS_PATH="${INSTALL_DIR}/requirements.txt"
DOCKER_COMPOSE_PATH="${INSTALL_DIR}/docker-compose.yml"
CMD_NAME="fuck"
INSTALL_PATH="/usr/local/bin/${CMD_NAME}"

# 3. Verificação de Dependências do Sistema (Docker)
echo "-> Verificando dependências do sistema..."
if ! command -v docker &> /dev/null; then
    echo "ERRO: Docker não encontrado. Por favor, instale o Docker e tente novamente."
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    echo "ERRO: Docker Compose não encontrado. Por favor, instale o Docker Compose e tente novamente."
    exit 1
fi
echo "Docker e Docker Compose encontrados."

# 4. Verificação dos Arquivos do Projeto
if [ ! -f "$DOCKER_COMPOSE_PATH" ]; then
    echo "ERRO: O arquivo 'docker-compose.yml' não foi encontrado."
    exit 1
fi

# 5. Subindo o Contêiner do Redis em background
echo "-> Iniciando o serviço do Redis via Docker Compose..."
# 'up -d' sobe os serviços em modo "detached" (em segundo plano)
docker-compose up -d --remove-orphans
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao iniciar o contêiner do Redis."
    exit 1
fi
echo "Serviço do Redis está rodando em segundo plano."

# 6. Instalação das dependências Python
echo "-> Instalando dependências Python com pip..."
if command -v pip3 &> /dev/null; then
    pip3 install -r "$REQUIREMENTS_PATH"
else
    pip install -r "$REQUIREMENTS_PATH"
fi
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao instalar as dependências do pip."
    exit 1
fi

# 7. Preparação do Comando 'fuck'
echo "-> Configurando o comando '${CMD_NAME}'..."
chmod +x "$MAIN_SCRIPT_PATH"
ln -sf "$MAIN_SCRIPT_PATH" "$INSTALL_PATH"
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao criar o link simbólico para o comando."
    exit 1
fi

# 8. Mensagem de Sucesso
echo ""
echo ">>> Instalação concluída com sucesso! <<<"
echo ""
echo "O serviço do Redis foi iniciado em um contêiner Docker e o comando '${CMD_NAME}' está pronto para uso."
echo "Para usar, basta abrir um novo terminal e digitar: ${CMD_NAME} <hash>"

exit 0
#!/bin/bash

# --- Script para instalar a ferramenta 'fuck' com um ambiente virtual dedicado ---

# 1. Verificação de Privilégios
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Por favor, execute este script como root ou com sudo."
  echo "Exemplo: sudo bash install.sh"
  exit 1
fi

# 2. Definição de Variáveis
INSTALL_DIR=$(pwd)
VENV_DIR="${INSTALL_DIR}/.venv"
REQUIREMENTS_PATH="${INSTALL_DIR}/requirements.txt"
CMD_NAME="fuck"
INSTALL_PATH="/usr/local/bin/${CMD_NAME}"

echo "Iniciando a instalação da ferramenta '${CMD_NAME}'..."

# 3. Verificação de Dependências do Sistema (python3-venv)
echo "-> Verificando se o pacote python3-venv está instalado..."
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    echo "AVISO: O pacote python3-venv não parece estar instalado. Tentando instalar..."
    apt-get update && apt-get install -y python3-venv
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao instalar python3-venv. Por favor, instale-o manualmente e tente novamente."
        exit 1
    fi
fi

# 4. Criação do Ambiente Virtual
echo "-> Criando ambiente virtual em ${VENV_DIR}..."
python3 -m venv "$VENV_DIR"
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao criar o ambiente virtual."
    exit 1
fi

# 5. Instalação das dependências Python no Ambiente Virtual
echo "-> Instalando dependências Python no ambiente virtual..."
# Usa o pip de dentro do .venv para instalar os pacotes
"$VENV_DIR/bin/pip" install -r "$REQUIREMENTS_PATH"
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao instalar as dependências do pip no ambiente virtual."
    exit 1
fi

# 6. Criação do Script de Inicialização
echo "-> Criando o comando '${CMD_NAME}' em ${INSTALL_PATH}..."
# Este script 'wrapper' garante que o Python correto (do .venv) seja usado
cat > "$INSTALL_PATH" << EOF
#!/bin/bash
# Wrapper para executar a aplicação F.U.C.K com seu ambiente virtual

# Caminho absoluto para o interpretador Python do ambiente virtual
VENV_PYTHON="${VENV_DIR}/bin/python"

# Caminho absoluto para o script principal
MAIN_SCRIPT="${INSTALL_DIR}/main.py"

# Executa o script principal com o Python do venv, passando todos os argumentos
exec "\$VENV_PYTHON" "\$MAIN_SCRIPT" "\$@"
EOF

# 7. Tornar o comando executável
chmod +x "$INSTALL_PATH"

# 8. Opcional: Manter o Docker Compose se o arquivo existir
if [ -f "${INSTALL_DIR}/docker-compose.yml" ]; then
    echo "-> Verificando ambiente Docker..."
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d --remove-orphans
        echo "Serviço do Redis está rodando em segundo plano via Docker."
    else
        echo "AVISO: docker-compose não encontrado. A inicialização do Redis foi pulada."
    fi
fi

# 9. Mensagem de Sucesso
echo ""
echo ">>> Instalação concluída com sucesso! <<<"
echo ""
echo "O comando '${CMD_NAME}' está pronto para uso e usará seu próprio ambiente Python isolado."
echo "Lembre-se de que o Redis precisa estar rodando (se não foi iniciado via Docker)."

exit 0
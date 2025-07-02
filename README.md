# F.U.C.K - Fast Universal Cracker Kit

F.U.C.K é uma ferramenta de linha de comando para consulta de hashes (hash lookup) que utiliza uma base de dados Redis populada a partir de wordlists. Sua principal característica é o pipeline de dados inteligente e automatizado, que cuida da geração dos hashes e do "seeding" (população) da base de forma autônoma e performática.

O projeto foi desenhado para ser uma ferramenta "instale e use". Um único script cuida de toda a configuração do ambiente, incluindo a inicialização do banco de dados Redis em um contêiner Docker.

## Funcionalidades Principais

-   **Instalação Simplificada:** Um único script (`install.sh`) configura todo o ambiente, incluindo a base de dados.
-   **Ambiente Dockerizado:** O Redis roda em um contêiner Docker, garantindo um ambiente isolado, consistente e sem a necessidade de instalar o Redis manualmente no sistema.
-   **Setup Automatizado:** Na primeira execução, a ferramenta automaticamente popula o banco de dados com os hashes gerados a partir das wordlists fornecidas.
-   **Comando Global:** Após a instalação, a ferramenta fica disponível globalmente através do comando `fuck`.
-   **Mecanismo de Atualização:** Um comando `--update` permite adicionar novas wordlists à base sem reprocessar as antigas.

---

## Arquitetura do Projeto

-   **`main.py`:** Orquestrador principal da aplicação, acessível globalmente pelo comando `fuck`.
-   **`data_manager.py`:** Contém toda a lógica de gerenciamento de dados (setup inicial, atualizações, seeding).
-   **`config.py`:** Centraliza as configurações do projeto.
-   **`install.sh`:** Script de instalação que configura o ambiente Docker, as dependências Python e o comando global.
-   **`uninstall.sh`:** Script para remover completamente a instalação e o ambiente Docker.
-   **`docker-compose.yml`:** Define o serviço do Redis que roda em segundo plano.
-   **`gerar_hashes.sh`:** Script em Bash otimizado para a geração de hashes em massa a partir das wordlists.

---

## Instalação

O processo de instalação foi projetado para ser o mais simples possível.

### Requisitos

-   Um sistema operacional baseado em Linux ou macOS.
-   **Docker** e **Docker Compose** instalados e em execução.
-   Git (para clonar o repositório).
-   Python 3.x e Pip.

### Passos para Instalação

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/luan-garcia/FUCK.git](https://github.com/luan-garcia/FUCK.git)
    cd FUCK
    ```

2.  **Execute o script de instalação:**
    Este comando precisa ser executado com `sudo`, pois ele irá instalar o comando `fuck` em `/usr/local/bin` e gerenciar o Docker.
    ```bash
    sudo bash install.sh
    ```

**O que o instalador faz?**
* Verifica se você tem Docker e Docker Compose.
* Inicia o serviço do Redis em um contêiner Docker em segundo plano.
* Instala as dependências Python (`redis`).
* Configura o comando `fuck` para ser acessível de qualquer lugar no seu terminal.

Ao final do processo, a ferramenta estará 100% pronta para uso.

---

## Como Usar

### 1. Primeira Execução (Setup Automático de Dados)

Na primeira vez que você usar o comando `fuck` após a instalação, ele irá automaticamente:
1.  Procurar por arquivos de wordlist na pasta `./wordlists/`.
2.  Gerar os hashes para todas as senhas encontradas.
3.  Popular a base de dados Redis com esses hashes.

Este processo pode levar algum tempo dependendo do tamanho das suas wordlists, mas só precisa ser executado uma vez.

### 2. Consultando uma Hash

Após o setup inicial, basta executar o comando `fuck` seguido da hash:
```bash
fuck 5d41402abc4b2a76b9719d911017c592
```

Ou rode sem argumentos para entrar no modo interativo:
```bash
fuck
```

### 3. Atualizando a Base com Novas Wordlists

1.  Adicione um novo arquivo `.txt` com senhas na pasta `wordlists/`.
2.  Execute o comando com o parâmetro `--update`:
    ```bash
    fuck --update
    ```
A ferramenta irá detectar e processar **apenas o novo arquivo**, adicionando os novos hashes à base de dados.

---

## Desinstalação

Para remover completamente a ferramenta e o seu ambiente:

1.  Navegue até o diretório do projeto.
2.  Execute o script de desinstalação com `sudo`:
    ```bash
    sudo bash uninstall.sh
    ```

Este comando irá parar e remover o contêiner do Redis, apagar os volumes de dados e remover o comando `fuck` do seu sistema.
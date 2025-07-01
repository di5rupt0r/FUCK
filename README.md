# Hash Lookup com Seeding Automático em Redis

Este projeto é uma ferramenta de linha de comando para consulta de hashes (hash lookup) que utiliza uma base de dados Redis populada a partir de wordlists. A principal característica é o seu pipeline de dados inteligente e automatizado, que cuida da geração dos hashes e do "seeding" (população) da base de forma autônoma e performática na primeira execução.

## Funcionalidades Principais

- **Setup Automatizado:** Na primeira execução, a ferramenta automaticamente:
    1.  Detecta as wordlists disponíveis.
    2.  Gera um CSV estruturado (`senha:hash1:hash2:...`) com múltiplos tipos de hash para cada senha.
    3.  Popula a base Redis com milhões de entradas de forma otimizada.
- **Consulta Instantânea:** As buscas por hash na base Redis são praticamente instantâneas (complexidade O(1)).
- **Mecanismo de Atualização Inteligente:** Um comando `--update` permite adicionar novas wordlists à base sem a necessidade de reprocessar as antigas.
- **Alta Performance:** O uso de scripts em Bash para a geração de hashes e `pipelines` do Redis para o seeding garante um desempenho ordens de magnitude superior a abordagens tradicionais em Python.

---

## Arquitetura do Projeto

O projeto é modularizado para garantir clareza e manutenibilidade.

-   **`main.py` - Orquestrador Principal**
    -   É o ponto de entrada da aplicação.
    -   Responsável por interpretar os argumentos da linha de comando (como a hash a ser buscada ou o parâmetro `--update`).
    -   Invoca o `data_manager` para realizar as tarefas de setup ou atualização.
    -   Executa a consulta final no Redis e exibe o resultado para o usuário.

-   **`data_manager.py` - O Motor da Aplicação**
    -   Encapsula toda a lógica de gerenciamento de dados.
    -   Contém a função `run_initial_setup`, que coordena todo o processo da primeira execução.
    -   Contém a função `run_update`, que gerencia a adição de novas wordlists.
    -   Chama o script `gerar_hashes.sh` para o processamento pesado dos arquivos.
    -   Contém a função `seed_redis_from_csv`, que usa `pipelines` para popular o Redis de forma eficiente.

-   **`config.py` - Arquivo de Configuração**
    -   Centraliza todas as variáveis de configuração, como os detalhes de conexão do Redis, caminhos de diretórios e nomes de chaves de controle. Facilita a adaptação do projeto para diferentes ambientes.

-   **`gerar_hashes.sh` - Script de Geração de Hashes**
    -   Um script em Bash otimizado para performance.
    -   Recebe uma wordlist como entrada e gera um arquivo CSV no formato `senha:md5:sha1:sha224:sha256:sha384:sha512`.
    -   Utiliza ferramentas nativas do sistema (`md5sum`, `sha1sum`, etc.) para garantir a máxima velocidade no cálculo dos hashes.

---

## Como Usar

### Requisitos

-   Python 3.x
-   Servidor Redis em execução.
-   Um ambiente com Bash e as ferramentas `coreutils` (padrão em Linux e macOS).
-   Dependências Python: `pip install redis`

### 1. Estrutura de Pastas

Organize seu projeto da seguinte forma:

```
/seu_projeto/
├── main.py
├── data_manager.py
├── config.py
├── gerar_hashes.sh
├── requirements.txt
└── wordlists/
    └── rockyou.txt
    └── outras_wordlists.txt
```

### 2. Primeira Execução (Setup Automático)

1.  Coloque todos os seus arquivos de wordlist (.txt) dentro da pasta `wordlists/`.
2.  Dê permissão de execução ao script Bash: `chmod +x gerar_hashes.sh`.
3.  Rode o programa principal:
    ```bash
    python main.py
    ```
4.  Aguarde. A ferramenta irá detectar que é a primeira vez, gerar todos os hashes e popular o Redis. Ao final, ela entrará em modo de consulta.

### 3. Consultando uma Hash

Após o setup inicial, basta executar o programa passando a hash como argumento:

```bash
python main.py 5d41402abc4b2a76b9719d911017c592
```

Ou rode sem argumentos para entrar em modo interativo:

```bash
python main.py
```

### 4. Atualizando a Base com Novas Wordlists

1.  Simplesmente adicione um novo arquivo de wordlist (ex: `novas_senhas.txt`) à pasta `wordlists/`.
2.  Execute o programa com o parâmetro `--update`:
    ```bash
    python main.py --update
    ```
3.  A ferramenta irá detectar **apenas o novo arquivo**, processá-lo e adicionar os novos hashes à base de dados existente.
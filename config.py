# config.py

# --- Configurações do Redis ---
REDIS_HOST = 'localhost'
REDIS_PORT = 6379
REDIS_DB = 0

# --- Chaves de Controle no Redis ---
# Chave que armazena os nomes das wordlists já processadas
PROCESSED_WORDLISTS_KEY = "hash_lookup:processed_wordlists"
# Chave que funciona como uma "flag" para saber se o primeiro seeding foi feito
INITIAL_SEED_COMPLETE_KEY = "hash_lookup:initial_seed_done"

# --- Caminhos de Arquivos ---
# Pasta onde suas wordlists (ex: rockyou.txt) estão ou serão colocadas
WORDLISTS_DIR = "./wordlists"
# Pasta para armazenar os arquivos CSV gerados
CSV_DIR = "./csv_data"
# Nome do arquivo CSV principal
MASTER_CSV_FILE = f"{CSV_DIR}/master_hashes.csv"

# --- Scripts ---
# Nome do script em BASH para gerar os hashes
GENERATE_HASHES_SCRIPT = "./gerar_hashes.sh"
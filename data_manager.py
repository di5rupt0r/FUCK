# data_manager.py

import subprocess
import os
import redis
from redis import exceptions
from logger import log
import config

def get_redis_connection():
    """Retorna uma conexão com o Redis."""
    try:
        r = redis.Redis(
            host=config.REDIS_HOST,
            port=config.REDIS_PORT,
            db=config.REDIS_DB,
            decode_responses=True  # Garante que hgetall retorna dict[str, str]
        )
        r.ping()
        return r
    except exceptions.ConnectionError as e:
        log(f"ERRO: Não foi possível conectar ao Redis em {config.REDIS_HOST}:{config.REDIS_PORT}. Verifique se ele está rodando.")
        log(f"Detalhe do erro: {e}")
        return None

def run_hash_generator(wordlist_path, output_csv_path):
    """
    Executa o script gerar_hashes.sh para uma wordlist específica.
    """
    if not os.path.exists(config.GENERATE_HASHES_SCRIPT):
        log(f"ERRO: Script gerador de hashes '{config.GENERATE_HASHES_SCRIPT}' não encontrado.")
        return False
        
    log(f"Gerando hashes para '{os.path.basename(wordlist_path)}'...")
    try:
        # Garante que o script tenha permissão de execução
        subprocess.run(['chmod', '+x', config.GENERATE_HASHES_SCRIPT], check=True)
        # Executa o script
        subprocess.run(
            [config.GENERATE_HASHES_SCRIPT, wordlist_path, output_csv_path],
            check=True
        )
        log(f"CSV gerado com sucesso em '{output_csv_path}'")
        return True
    except subprocess.CalledProcessError as e:
        log(f"ERRO ao executar o script gerador de hashes. Código de saída: {e.returncode}")
        return False
    except FileNotFoundError:
        log("ERRO: O comando 'chmod' ou o script não foi encontrado. Verifique se você está em um ambiente Linux/macOS.")
        return False


def seed_redis_from_csv(r, csv_path):
    """
    Popula o Redis com os dados de um arquivo CSV estruturado.
    """
    log(f"Iniciando seeding do Redis a partir de '{csv_path}'...")
    pipe = r.pipeline()
    total_entradas = 0
    
    with open(csv_path, 'r', encoding='utf-8') as f:
        cabecalho = f.readline().strip().split(':')
        tipos_hash = cabecalho[1:]

        for linha in f:
            partes = linha.strip().split(':')
            if len(partes) != len(cabecalho):
                continue

            senha = partes[0]
            lista_hashes = partes[1:]

            for i, valor_hash in enumerate(lista_hashes):
                tipo_hash = tipos_hash[i].upper()
                pipe.hset(valor_hash, mapping={'senha': senha, 'tipo': tipo_hash})
                total_entradas += 1

            if total_entradas % 100000 == 0:
                log(f"... {total_entradas} entradas na fila. Enviando para o Redis.")
                pipe.execute()

    log("Enviando lote final de dados...")
    pipe.execute()
    log(f"Seeding concluído para este arquivo. {total_entradas} novas entradas adicionadas.")
    return True


def run_initial_setup(r):
    """
    Executa toda a rotina de configuração inicial se for a primeira vez.
    """
    log("Verificando configuração inicial...")
    if r.get(config.INITIAL_SEED_COMPLETE_KEY):
        log("Configuração inicial já foi realizada. Pulando.")
        return True

    log("Primeira execução detectada. Iniciando processo de configuração e seeding...")
    
    # 1. Garantir que os diretórios existem
    os.makedirs(config.WORDLISTS_DIR, exist_ok=True)
    os.makedirs(config.CSV_DIR, exist_ok=True)

    # 2. Verificar se há wordlists
    wordlists = [f for f in os.listdir(config.WORDLISTS_DIR) if os.path.isfile(os.path.join(config.WORDLISTS_DIR, f))]
    if not wordlists:
        log(f"AVISO: Nenhuma wordlist encontrada no diretório '{config.WORDLISTS_DIR}'.")
        log("Por favor, adicione arquivos de wordlist e rode o programa com o parâmetro --update.")
        return False
    
    # 3. Gerar o CSV mestre
    master_csv_path = config.MASTER_CSV_FILE
    temp_files = []
    for wl_file in wordlists:
        wl_path = os.path.join(config.WORDLISTS_DIR, wl_file)
        temp_csv = os.path.join(config.CSV_DIR, f"temp_{wl_file}.csv")
        if run_hash_generator(wl_path, temp_csv):
            temp_files.append(temp_csv)
        else:
            log(f"Falha ao gerar hashes para {wl_file}. Abortando.")
            return False

    # Juntar todos os CSVs temporários em um mestre
    with open(master_csv_path, 'w') as outfile:
        for i, fname in enumerate(temp_files):
            with open(fname, 'r') as infile:
                if i != 0:
                    next(infile) # Pula o cabeçalho dos arquivos subsequentes
                for line in infile:
                    if line.strip():  # só escreve linhas não vazias
                        outfile.write(line)    
    # Limpa arquivos temporários
    for fname in temp_files:
        os.remove(fname)

    # 4. Popular o Redis
    if not seed_redis_from_csv(r, master_csv_path):
        return False

    # 5. Marcar como concluído e salvar as wordlists processadas
    r.set(config.INITIAL_SEED_COMPLETE_KEY, "1")
    for wl_file in wordlists:
        r.sadd(config.PROCESSED_WORDLISTS_KEY, wl_file)
        
    log("\n>>> Configuração inicial e seeding concluídos com sucesso! <<<\n")
    return True


def run_update(r):
    """
    Verifica por novas wordlists e atualiza a base do Redis.
    """
    log("Iniciando modo de atualização...")
    
    processed_wordlists = r.smembers(config.PROCESSED_WORDLISTS_KEY)
    current_wordlists = set(os.listdir(config.WORDLISTS_DIR))
    
    new_wordlists = list(current_wordlists - processed_wordlists)

    if not new_wordlists:
        log("Nenhuma nova wordlist encontrada. A base já está atualizada.")
        return True

    log(f"Novas wordlists detectadas: {', '.join(new_wordlists)}")
    
    for wl_file in new_wordlists:
        wl_path = os.path.join(config.WORDLISTS_DIR, wl_file)
        temp_csv = os.path.join(config.CSV_DIR, f"update_{wl_file}.csv")
        
        # Gera hashes apenas para a nova wordlist
        if not run_hash_generator(wl_path, temp_csv):
            log(f"Falha ao processar {wl_file}. Pulando para a próxima.")
            continue
            
        # Popula o Redis com os novos dados
        if not seed_redis_from_csv(r, temp_csv):
            log(f"Falha ao popular o Redis com {wl_file}. Pulando para a próxima.")
            os.remove(temp_csv) # Limpa o CSV temporário
            continue
            
        # Se tudo deu certo, marca a wordlist como processada
        r.sadd(config.PROCESSED_WORDLISTS_KEY, wl_file)
        os.remove(temp_csv) # Limpa o CSV temporário
        log(f"'{wl_file}' processada e adicionada à base com sucesso.")

    log("\n>>> Processo de atualização concluído! <<<\n")
    return True
# main.py

import sys
import argparse
import data_manager
from logger import log
import config
from typing import cast, Dict

def main():
    parser = argparse.ArgumentParser(
        description="Ferramenta de lookup de hash em uma base Redis.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        'hash_input', 
        nargs='?', 
        default=None,
        help="A hash a ser procurada. Se não for fornecida em modo interativo."
    )
    parser.add_argument(
        '--update',
        action='store_true',
        help="Verifica por novas wordlists e atualiza a base de dados do Redis."
    )
    args = parser.parse_args()

    r = data_manager.get_redis_connection()
    if not r:
        sys.exit(1)

    # --- Lógica de Atualização ---
    if args.update:
        data_manager.run_update(r)
        sys.exit(0)

    # --- Lógica de Configuração Inicial ---
    if not data_manager.run_initial_setup(r):
        log("Houve um erro na configuração inicial. A aplicação não pode continuar.")
        sys.exit(1)
        
    # --- Lógica Principal de Lookup ---
    hash_recebida = args.hash_input
    if not hash_recebida:
        try:
            hash_recebida = input("Insira a hash para consulta:\n-> ")
        except KeyboardInterrupt:
            log("\nOperação cancelada.")
            sys.exit(0)

    hash_recebida = hash_recebida.strip().lower()
    if not hash_recebida:
        log("Hash não fornecida.")
        sys.exit(1)

    if r.exists(hash_recebida):
        dados = cast(Dict[str, str], r.hgetall(hash_recebida))
        if not dados:
            log("Hash encontrada, mas sem dados associados.")
            sys.exit(1)
        log("\n--- Hash Encontrada! ---")
        log(f"Tipo:  {dados['tipo'] if 'tipo' in dados else 'N/A'}")
        log(f"Senha: {dados['senha'] if 'senha' in dados else 'N/A'}")
        log("------------------------")
    else:
        log("\nHash não encontrada na base de dados.")


if __name__ == "__main__":
    main()
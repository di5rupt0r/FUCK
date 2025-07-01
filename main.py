import redis
import hashlib

def identifier(hash_str) -> str:
    tamanho = len(hash_str)

    hash_str = hash_str.lower()

    if not all(c in '0123456789abcdef' for c in hash_str):
        return "Formato inválido (não hexadecimal)"
    if tamanho == 32:
        return "MD5"
    elif tamanho == 40:
        return "SHA-1"
    elif tamanho == 56:
        return "SHA-224"
    elif tamanho == 64:
        return "SHA-256"
    elif tamanho == 96:
        return "SHA-384"
    elif tamanho == 128:
        return "SHA-512"
    else:
        return "Tipo de hash desconhecido ou tamanho inválido"

r = redis.Redis(
    host='localhost',
    port=6379,
    db=0,
    username='Redis',        
    password='R3d1s!'        
)

hash_recebida = input("Insira o tipo de hash: \n->")
tipo_hash = identifier(hash_recebida)
print(f'O tipo de hash é: {tipo_hash}')

if r.exists(hash_recebida):
    dados = r.hgetall(hash_recebida)
    print("Hash encontrada!")
    print("Tipo:", dados[b"tipo"].decode())
    print("Senha:", dados[b"senha"].decode())
else:
    print("Hash não encontrada.")

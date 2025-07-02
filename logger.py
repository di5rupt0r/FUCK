# logger.py
import datetime

def log(message):
    """Imprime uma mensagem com um timestamp no formato [YYYY-MM-DD HH:MM:SS]."""
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {message}")
"""
Configuração do cliente Redis para o Sentinela
"""
import redis
import os
from typing import Optional

# Configuração do Redis
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", None)

# Cliente Redis global
redis_client: Optional[redis.Redis] = None

def get_redis_client() -> redis.Redis:
    """
    Obtém ou cria uma instância do cliente Redis
    
    Returns:
        redis.Redis: Cliente Redis configurado
    """
    global redis_client
    
    if redis_client is None:
        redis_client = redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            db=REDIS_DB,
            password=REDIS_PASSWORD,
            decode_responses=True,
            socket_connect_timeout=2,
            socket_timeout=2
        )
    
    return redis_client

def check_redis_connection() -> bool:
    """
    Verifica conexão com o Redis usando PING
    
    Returns:
        bool: True se conectado, False caso contrário
    """
    try:
        client = get_redis_client()
        response = client.ping()
        return response is True
    except Exception as e:
        print(f"Erro ao conectar ao Redis: {e}")
        return False

def get_redis_info() -> dict:
    """
    Obtém informações do Redis
    
    Returns:
        dict: Informações do servidor Redis ou erro
    """
    try:
        client = get_redis_client()
        info = client.info()
        return {
            "connected": True,
            "version": info.get("redis_version", "unknown"),
            "uptime_seconds": info.get("uptime_in_seconds", 0),
            "connected_clients": info.get("connected_clients", 0)
        }
    except Exception as e:
        return {
            "connected": False,
            "error": str(e)
        }

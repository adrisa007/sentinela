"""
Configuração de Rate Limiting com SlowAPI
==========================================

Implementa proteção contra abuso e ataques DDoS usando SlowAPI.

Repositório: adrisa007/sentinela (ID: 1112237272)
Limite Global: 300 requisições por minuto
"""
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi import Request, Response
from fastapi.responses import JSONResponse
import logging

logger = logging.getLogger(__name__)


# ============ Configuração do Limiter ============

def get_identifier(request: Request) -> str:
    """
    Obtém identificador único para rate limiting
    
    Estratégia de identificação (em ordem de prioridade):
    1. User ID autenticado (se houver)
    2. X-Forwarded-For header (proxy/load balancer)
    3. X-Real-IP header (nginx)
    4. IP remoto direto
    
    Returns:
        str: Identificador único do cliente
    """
    # Tentar obter user_id do token (se autenticado)
    if hasattr(request.state, 'user_id'):
        return f"user:{request.state.user_id}"
    
    # Verificar headers de proxy
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        # Pegar primeiro IP da lista (IP original do cliente)
        return forwarded_for.split(",")[0].strip()
    
    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip
    
    # Fallback para IP remoto direto
    return get_remote_address(request)


# Criar instância do Limiter
limiter = Limiter(
    key_func=get_identifier,
    default_limits=["300/minute"],  # Limite global: 300 req/min
    storage_uri="memory://",  # Usar memória (para produção, usar Redis)
    strategy="fixed-window",  # Estratégia de janela fixa
    headers_enabled=True,  # Adicionar headers de rate limit na resposta
)


# ============ Handler de Erro Customizado ============

def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded) -> Response:
    """
    Handler customizado para erro de rate limit excedido
    
    Retorna:
    - Status Code: 429 Too Many Requests
    - Headers com informações de rate limit
    - Mensagem amigável em JSON
    """
    # Obter identificador do cliente
    identifier = get_identifier(request)
    
    # Log de tentativa de rate limit
    logger.warning(
        f"🚫 Rate limit excedido - "
        f"Identificador: {identifier} - "
        f"Rota: {request.url.path} - "
        f"Método: {request.method}"
    )
    
    return JSONResponse(
        status_code=429,
        content={
            "error": "Rate Limit Exceeded",
            "message": "Você excedeu o limite de requisições permitidas. Tente novamente em alguns instantes.",
            "detail": {
                "limit": "300 requisições por minuto",
                "retry_after": "60 segundos",
                "identifier": identifier[:20] + "..." if len(identifier) > 20 else identifier
            }
        },
        headers={
            "Retry-After": "60",
            "X-RateLimit-Limit": "300",
            "X-RateLimit-Remaining": "0",
            "X-RateLimit-Reset": str(int(exc.retry_after) if hasattr(exc, 'retry_after') else 60)
        }
    )


# ============ Funções Auxiliares ============

def get_rate_limit_info(request: Request) -> dict:
    """
    Obtém informações atuais de rate limit
    
    Returns:
        dict: Informações de limite, restante e reset
    """
    try:
        # Extrair do limiter
        key = get_identifier(request)
        # TODO: Implementar lógica para obter info do storage
        return {
            "limit": 300,
            "remaining": "N/A",  # Requer integração com storage
            "reset": "N/A"
        }
    except Exception as e:
        logger.error(f"Erro ao obter rate limit info: {e}")
        return {"limit": 300, "remaining": "N/A", "reset": "N/A"}


def exempt_from_rate_limit(request: Request) -> bool:
    """
    Verifica se uma requisição deve ser isenta de rate limiting
    
    Casos de isenção:
    - Health checks
    - Rotas de documentação
    - IPs de whitelist (configurável)
    
    Returns:
        bool: True se deve ser isento
    """
    # Health check
    if request.url.path == "/health":
        return True
    
    # Documentação
    if request.url.path in ["/docs", "/redoc", "/openapi.json"]:
        return True
    
    # Rotas estáticas
    if request.url.path.startswith("/static"):
        return True
    
    # TODO: Implementar whitelist de IPs (se necessário)
    # whitelist_ips = ["127.0.0.1", "::1"]
    # if get_identifier(request) in whitelist_ips:
    #     return True
    
    return False

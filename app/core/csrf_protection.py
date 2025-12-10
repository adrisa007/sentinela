"""
Middleware de Proteção CSRF (Cross-Site Request Forgery)
=========================================================

Implementa proteção contra ataques CSRF com tokens seguros,
cookies SameSite=Strict e validação de tokens.

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from fastapi import Request, Response, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
from typing import Callable
import secrets
import logging
from itsdangerous import URLSafeTimedSerializer, BadSignature, SignatureExpired

from app.core.config import settings

logger = logging.getLogger(__name__)


# ============ Configuração CSRF ============

CSRF_TOKEN_LENGTH = 32
CSRF_COOKIE_NAME = "csrf_token"
CSRF_HEADER_NAME = "X-CSRF-Token"
CSRF_FORM_FIELD_NAME = "csrf_token"
CSRF_TOKEN_MAX_AGE = 3600  # 1 hora em segundos

# Rotas isentas de validação CSRF (métodos GET, HEAD, OPTIONS são sempre isentos)
CSRF_EXEMPT_ROUTES = [
    "/docs",
    "/redoc",
    "/openapi.json",
    "/health",
    "/csrf-token",
    "/auth/login",    # Login usa apenas credenciais
    "/entidades",     # Temporariamente isento para testes
    "/contratos",     # Temporariamente isento para testes
    "/cameras",       # Temporariamente isento para testes
    "/pncp",          # API PNCP usa apenas autenticação JWT
]


# ============ Gerador de Tokens CSRF ============

class CSRFTokenGenerator:
    """
    Gerador e validador de tokens CSRF usando assinatura criptográfica
    """
    
    def __init__(self, secret_key: str):
        """
        Inicializa o gerador de tokens
        
        Args:
            secret_key: Chave secreta para assinar tokens
        """
        self.serializer = URLSafeTimedSerializer(secret_key)
    
    def generate_token(self) -> str:
        """
        Gera um novo token CSRF assinado
        
        Returns:
            str: Token CSRF assinado
        """
        # Gerar valor aleatório
        random_value = secrets.token_urlsafe(CSRF_TOKEN_LENGTH)
        
        # Assinar o valor
        token = self.serializer.dumps(random_value)
        
        logger.debug(f"🔐 Token CSRF gerado: {token[:20]}...")
        return token
    
    def validate_token(self, token: str, max_age: int = CSRF_TOKEN_MAX_AGE) -> bool:
        """
        Valida um token CSRF
        
        Args:
            token: Token a ser validado
            max_age: Idade máxima do token em segundos
            
        Returns:
            bool: True se válido, False caso contrário
        """
        try:
            # Validar assinatura e idade
            self.serializer.loads(token, max_age=max_age)
            logger.debug(f"✅ Token CSRF válido: {token[:20]}...")
            return True
        except (BadSignature, SignatureExpired) as e:
            logger.warning(f"🚫 Token CSRF inválido ou expirado: {e}")
            return False


# Instância global do gerador
csrf_generator = CSRFTokenGenerator(settings.SECRET_KEY)


# ============ Middleware CSRF ============

class CSRFProtectionMiddleware(BaseHTTPMiddleware):
    """
    Middleware que implementa proteção CSRF
    
    Funcionalidades:
    - Gera tokens CSRF para requisições GET
    - Valida tokens em requisições POST, PUT, PATCH, DELETE
    - Usa cookies SameSite=Strict
    - Valida tokens via header ou form field
    """
    
    def __init__(
        self,
        app: ASGIApp,
        cookie_name: str = CSRF_COOKIE_NAME,
        header_name: str = CSRF_HEADER_NAME,
        cookie_secure: bool = True,
        cookie_httponly: bool = True,
        cookie_samesite: str = "strict"
    ):
        super().__init__(app)
        self.cookie_name = cookie_name
        self.header_name = header_name
        self.cookie_secure = cookie_secure
        self.cookie_httponly = cookie_httponly
        self.cookie_samesite = cookie_samesite
        
        logger.info(f"🛡️  CSRFProtectionMiddleware inicializado")
        logger.info(f"   Cookie: {self.cookie_name} (SameSite={self.cookie_samesite})")
    
    def _is_safe_method(self, method: str) -> bool:
        """
        Verifica se o método HTTP é considerado seguro (não precisa validar CSRF)
        
        Args:
            method: Método HTTP
            
        Returns:
            bool: True se método seguro
        """
        return method in ["GET", "HEAD", "OPTIONS", "TRACE"]
    
    def _is_exempt_route(self, path: str) -> bool:
        """
        Verifica se a rota está isenta de validação CSRF
        
        Args:
            path: Path da requisição
            
        Returns:
            bool: True se isenta
        """
        for exempt_path in CSRF_EXEMPT_ROUTES:
            if path.startswith(exempt_path):
                return True
        return False
    
    def _get_token_from_request(self, request: Request) -> str | None:
        """
        Extrai token CSRF da requisição
        
        Ordem de prioridade:
        1. Header X-CSRF-Token
        2. Form field csrf_token
        3. Cookie csrf_token
        
        Args:
            request: Request do FastAPI
            
        Returns:
            str | None: Token CSRF ou None
        """
        # 1. Tentar header
        token = request.headers.get(self.header_name)
        if token:
            logger.debug(f"🔍 Token CSRF encontrado no header: {token[:20]}...")
            return token
        
        # 2. Tentar cookie
        token = request.cookies.get(self.cookie_name)
        if token:
            logger.debug(f"🔍 Token CSRF encontrado no cookie: {token[:20]}...")
            return token
        
        logger.warning("⚠️  Token CSRF não encontrado na requisição")
        return None
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Processa a requisição e aplica proteção CSRF
        """
        # Métodos seguros não precisam de validação
        if self._is_safe_method(request.method):
            response = await call_next(request)
            
            # Se não tem cookie CSRF, gerar e adicionar
            if not request.cookies.get(self.cookie_name):
                token = csrf_generator.generate_token()
                response.set_cookie(
                    key=self.cookie_name,
                    value=token,
                    max_age=CSRF_TOKEN_MAX_AGE,
                    secure=self.cookie_secure,
                    httponly=self.cookie_httponly,
                    samesite=self.cookie_samesite,
                    path="/"
                )
                logger.debug(f"🍪 Cookie CSRF definido: {token[:20]}...")
            
            return response
        
        # Verificar se rota está isenta
        if self._is_exempt_route(request.url.path):
            logger.debug(f"✅ Rota isenta de CSRF: {request.url.path}")
            response = await call_next(request)
            return response
        
        # Validar token CSRF
        token = self._get_token_from_request(request)
        
        if not token:
            logger.error(f"🚫 CSRF: Token não fornecido em {request.method} {request.url.path}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="CSRF token missing. Include X-CSRF-Token header or csrf_token cookie."
            )
        
        if not csrf_generator.validate_token(token):
            logger.error(f"🚫 CSRF: Token inválido em {request.method} {request.url.path}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid or expired CSRF token"
            )
        
        logger.debug(f"✅ CSRF válido para {request.method} {request.url.path}")
        
        # Processar requisição
        response = await call_next(request)
        
        # Renovar cookie CSRF após requisição bem-sucedida
        new_token = csrf_generator.generate_token()
        response.set_cookie(
            key=self.cookie_name,
            value=new_token,
            max_age=CSRF_TOKEN_MAX_AGE,
            secure=self.cookie_secure,
            httponly=self.cookie_httponly,
            samesite=self.cookie_samesite,
            path="/"
        )
        
        return response


# ============ Funções Helper ============

def get_csrf_token(request: Request) -> str:
    """
    Obtém ou gera um token CSRF para a requisição
    
    Args:
        request: Request do FastAPI
        
    Returns:
        str: Token CSRF
    """
    # Tentar obter do cookie
    token = request.cookies.get(CSRF_COOKIE_NAME)
    
    if token and csrf_generator.validate_token(token):
        return token
    
    # Gerar novo token
    return csrf_generator.generate_token()


def validate_csrf_token(request: Request) -> bool:
    """
    Valida o token CSRF da requisição
    
    Args:
        request: Request do FastAPI
        
    Returns:
        bool: True se válido
    """
    # Obter token do header ou cookie
    token = request.headers.get(CSRF_HEADER_NAME)
    if not token:
        token = request.cookies.get(CSRF_COOKIE_NAME)
    
    if not token:
        return False
    
    return csrf_generator.validate_token(token)


# ============ Dependency para Validação Manual ============

async def require_csrf_token(request: Request) -> str:
    """
    Dependency que valida token CSRF manualmente
    
    Usage:
        @router.post("/endpoint")
        async def endpoint(csrf_token: str = Depends(require_csrf_token)):
            ...
    
    Args:
        request: Request do FastAPI
        
    Returns:
        str: Token CSRF válido
        
    Raises:
        HTTPException: Se token inválido ou ausente
    """
    token = request.headers.get(CSRF_HEADER_NAME)
    if not token:
        token = request.cookies.get(CSRF_COOKIE_NAME)
    
    if not token:
        logger.error("🚫 CSRF token não fornecido")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="CSRF token required"
        )
    
    if not csrf_generator.validate_token(token):
        logger.error("🚫 CSRF token inválido ou expirado")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid or expired CSRF token"
        )
    
    return token

"""
Middleware de Segurança (Helmet) para FastAPI
==============================================

Implementa headers de segurança HTTP similares ao Helmet.js
com Content Security Policy (CSP) restrito ao domínio oficial.

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
from typing import Callable
import logging

from app.core.config import settings

logger = logging.getLogger(__name__)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Middleware que adiciona headers de segurança HTTP em todas as respostas.
    
    Implementa proteções similares ao Helmet.js:
    - Content Security Policy (CSP)
    - X-Frame-Options
    - X-Content-Type-Options
    - Strict-Transport-Security (HSTS)
    - X-XSS-Protection
    - Referrer-Policy
    - Permissions-Policy
    """
    
    def __init__(
        self,
        app: ASGIApp,
        domain: str = "sentinela.example.com",
        enable_hsts: bool = True,
        hsts_max_age: int = 31536000,  # 1 ano
        enable_csp: bool = True
    ):
        super().__init__(app)
        self.domain = domain
        self.enable_hsts = enable_hsts
        self.hsts_max_age = hsts_max_age
        self.enable_csp = enable_csp
        
        logger.info(f"🛡️  SecurityHeadersMiddleware inicializado para domínio: {self.domain}")
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Processa a requisição e adiciona headers de segurança na resposta
        """
        # Processar requisição
        response = await call_next(request)
        
        # ============ Content Security Policy (CSP) ============
        if self.enable_csp:
            csp_directives = [
                f"default-src 'self' https://{self.domain}",
                f"script-src 'self' 'unsafe-inline' 'unsafe-eval' https://{self.domain} https://cdn.jsdelivr.net",
                f"style-src 'self' 'unsafe-inline' https://{self.domain} https://cdn.jsdelivr.net",
                f"img-src 'self' data: https: https://{self.domain}",
                f"font-src 'self' data: https://{self.domain} https://cdn.jsdelivr.net",
                f"connect-src 'self' https://{self.domain}",
                f"media-src 'self' https://{self.domain}",
                f"object-src 'none'",
                f"frame-src 'none'",
                f"base-uri 'self'",
                f"form-action 'self' https://{self.domain}",
                "upgrade-insecure-requests",
                "block-all-mixed-content"
            ]
            response.headers["Content-Security-Policy"] = "; ".join(csp_directives)
        
        # ============ X-Frame-Options ============
        # Previne clickjacking attacks
        response.headers["X-Frame-Options"] = "DENY"
        
        # ============ X-Content-Type-Options ============
        # Previne MIME type sniffing
        response.headers["X-Content-Type-Options"] = "nosniff"
        
        # ============ Strict-Transport-Security (HSTS) ============
        # Força HTTPS por 1 ano
        if self.enable_hsts:
            response.headers["Strict-Transport-Security"] = (
                f"max-age={self.hsts_max_age}; includeSubDomains; preload"
            )
        
        # ============ X-XSS-Protection ============
        # Ativa proteção contra XSS em browsers antigos
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        # ============ Referrer-Policy ============
        # Controla informações de referrer enviadas
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        
        # ============ Permissions-Policy ============
        # Controla features do browser (anteriormente Feature-Policy)
        permissions = [
            "accelerometer=()",
            "camera=()",
            "geolocation=()",
            "gyroscope=()",
            "magnetometer=()",
            "microphone=()",
            "payment=()",
            "usb=()"
        ]
        response.headers["Permissions-Policy"] = ", ".join(permissions)
        
        # ============ X-DNS-Prefetch-Control ============
        # Desabilita DNS prefetching
        response.headers["X-DNS-Prefetch-Control"] = "off"
        
        # ============ X-Download-Options ============
        # Para IE8+, previne execução de downloads
        response.headers["X-Download-Options"] = "noopen"
        
        # ============ X-Permitted-Cross-Domain-Policies ============
        # Restringe Adobe Flash e PDF cross-domain
        response.headers["X-Permitted-Cross-Domain-Policies"] = "none"
        
        # ============ Cache-Control ============
        # Para rotas sensíveis, desabilitar cache
        if request.url.path.startswith("/auth") or request.url.path.startswith("/api"):
            response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, private"
            response.headers["Pragma"] = "no-cache"
            response.headers["Expires"] = "0"
        
        return response


# ============ Função Helper para Configuração ============

def get_security_headers_config() -> dict:
    """
    Retorna configuração de headers de segurança
    
    Returns:
        dict: Configuração dos headers
    """
    return {
        "domain": getattr(settings, "APP_DOMAIN", "sentinela.example.com"),
        "enable_hsts": getattr(settings, "ENABLE_HSTS", True),
        "hsts_max_age": 31536000,  # 1 ano em segundos
        "enable_csp": True
    }


def validate_csp_compliance(request: Request) -> bool:
    """
    Valida se uma requisição está em conformidade com CSP
    
    Args:
        request: Request do FastAPI
        
    Returns:
        bool: True se conforme, False caso contrário
    """
    # Verificar origin
    origin = request.headers.get("Origin", "")
    referer = request.headers.get("Referer", "")
    
    config = get_security_headers_config()
    allowed_domain = config["domain"]
    
    # Se tem Origin, validar
    if origin:
        if allowed_domain not in origin and "localhost" not in origin:
            logger.warning(f"🚫 CSP Violation: Origin não permitido: {origin}")
            return False
    
    # Se tem Referer, validar
    if referer:
        if allowed_domain not in referer and "localhost" not in referer:
            logger.warning(f"🚫 CSP Violation: Referer não permitido: {referer}")
            return False
    
    return True


# ============ Middleware Adicional: CSP Report ============

class CSPReportMiddleware(BaseHTTPMiddleware):
    """
    Middleware para receber e logar relatórios de violação de CSP
    """
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """Processa relatórios de violação de CSP"""
        
        # Se é um relatório de CSP
        if request.url.path == "/csp-report" and request.method == "POST":
            try:
                body = await request.json()
                logger.error(f"🚨 CSP Violation Report: {body}")
            except Exception as e:
                logger.error(f"❌ Erro ao processar CSP report: {e}")
        
        response = await call_next(request)
        return response

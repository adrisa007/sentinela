from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.database import init_db
from app.routers import auth_router, entidades_router, cameras, contratos, health
from app.core.config import settings
from app.core.rate_limit import limiter, rate_limit_exceeded_handler, exempt_from_rate_limit
from app.core.security_headers import SecurityHeadersMiddleware, get_security_headers_config
from app.core.csrf_protection import CSRFProtectionMiddleware, get_csrf_token

init_db()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="""
    🛡️ **Sentinela** - Sistema de Autenticação e Controle de Acesso
    
    **Validações de Segurança:**
    - ✅ JWT (JSON Web Tokens,
    openapi_url="/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc")
    - ✅ MFA TOTP - Obrigatório para ROOT/GESTOR
    - ✅ RBAC (Role-Based Access Control)
    - ✅ Validação de Entidade Ativa
    - ✅ Rate Limiting: 300/min (global), 10/min (login)
    - ✅ Security Headers (Helmet): CSP, HSTS, X-Frame-Options
    - ✅ CSRF Protection: Tokens com cookies SameSite=Strict
    """
)

# ============ Middlewares (ORDEM IMPORTA!) ============

# 1. Security Headers (Helmet)
security_config = get_security_headers_config()
app.add_middleware(
    SecurityHeadersMiddleware,
    domain=security_config["domain"],
    enable_hsts=security_config["enable_hsts"],
    hsts_max_age=security_config["hsts_max_age"],
    enable_csp=security_config["enable_csp"]
)

# 2. CSRF Protection
app.add_middleware(
    CSRFProtectionMiddleware,
    cookie_secure=getattr(settings, "ENVIRONMENT", "development") == "production",
    cookie_httponly=True,
    cookie_samesite="strict"
)

# 3. CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 4. Rate Limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)


@app.middleware("http")
async def rate_limit_exemption_middleware(request: Request, call_next):
    """Middleware de isenção de rate limit"""
    if exempt_from_rate_limit(request):
        response = await call_next(request)
        return response
    response = await call_next(request)
    return response


# ============ Registrar Routers ============

app.include_router(health.router)
app.include_router(auth_router.router)
app.include_router(entidades_router.router)
app.include_router(cameras.router)
app.include_router(contratos.router)

@app.get("/", response_model=dict)
async def root():
    """
    Endpoint raiz da API Sentinela
    
    Returns:
        dict: Mensagem de boas-vindas e informações da aplicação
    """
    return {
        "rate_limiting": {
            "enabled": True,
            "limit": "300/minute",
            "login_limit": "10/minute"
        },
        "message": "Sentinela Python rodando no Railway! Vigilância total, risco zero.",
        "url": "https://web-production-8355.up.railway.app",
        "service": "sentinela",
        "status": "online",
        "endpoints": {
            "docs": "/docs",
            "redoc": "/redoc",
            "health": "/health",
            "health_live": "/health/live",
            "health_ready": "/health/ready"
        }
    }


@app.get("/", response_model=dict)
async def root():
    """
    Endpoint raiz da API Sentinela
    
    Returns:
        dict: Mensagem de boas-vindas e informações da aplicação
    """
    return {
        "rate_limiting": {
            "enabled": True,
            "limit": "300/minute",
            "login_limit": "10/minute"
        },
        "message": "Sentinela Python rodando no Railway! Vigilância total, risco zero.",
        "url": "https://web-production-8355.up.railway.app",
        "service": "sentinela",
        "status": "online",
        "endpoints": {
            "docs": "/docs",
            "redoc": "/redoc",
            "health": "/health",
            "health_live": "/health/live",
            "health_ready": "/health/ready"
        }
    }


@app.get("/", response_model=dict)
async def root():
    """
    Endpoint raiz da API Sentinela
    
    Returns:
        dict: Mensagem de boas-vindas e informações da aplicação
    """
    return {
        "rate_limiting": {
            "enabled": True,
            "limit": "300/minute",
            "login_limit": "10/minute"
        },
        "message": "Sentinela Python rodando no Railway! Vigilância total, risco zero.",
        "url": "https://web-production-8355.up.railway.app",
        "service": "sentinela",
        "status": "online",
        "endpoints": {
            "docs": "/docs",
            "redoc": "/redoc",
            "health": "/health",
            "health_live": "/health/live",
            "health_ready": "/health/ready"
        }
    }



# ============ Rotas Públicas ============

@app.get("/", tags=["Sistema"])
@limiter.limit("300/minute")
async def root(request: Request):
    """🏠 Rota raiz"""
    return JSONResponse(content={
        "app": settings.APP_NAME,
        "version": settings.VERSION,
        "docs": "/docs",
        "security": {
            "jwt": "✅ Enabled",
            "mfa_totp": "✅ Required (ROOT/GESTOR)",
            "rbac": "✅ Enabled",
            "rate_limiting": "✅ 300/min (global), 10/min (login)",
            "security_headers": "✅ Helmet enabled",
            "csrf_protection": "✅ Enabled (SameSite=Strict)",
            "domain": security_config["domain"]
        }
    })


@app.get("/health", tags=["Sistema"])
async def health(request: Request):
    """💚 Health check"""
    return JSONResponse(content={
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.VERSION
    })


@app.get("/csrf-token", tags=["Segurança"])
async def get_csrf_token_endpoint(request: Request):
    """
    🔐 **Obter Token CSRF**
    
    Retorna um token CSRF válido para usar em requisições POST/PUT/PATCH/DELETE.
    
    **Como usar:**
    1. Faça GET /csrf-token
    2. Copie o token da resposta
    3. Inclua em requisições via header X-CSRF-Token ou cookie csrf_token
    
    **Response:**
    ```json
    {
      "csrf_token": "eyJhbGc...",
      "expires_in": 3600,
      "usage": {
        "header": "X-CSRF-Token: <token>",
        "cookie": "csrf_token=<token>"
      }
    }
    ```
    """
    token = get_csrf_token(request)
    
    response = JSONResponse(content={
        "csrf_token": token,
        "expires_in": 3600,
        "usage": {
            "header": f"{CSRF_HEADER_NAME}: {token}",
            "cookie": f"{CSRF_COOKIE_NAME}={token}",
            "example_curl": f'curl -X POST https://api.example.com/endpoint -H "{CSRF_HEADER_NAME}: {token}"'
        },
        "info": {
            "cookie_name": CSRF_COOKIE_NAME,
            "header_name": CSRF_HEADER_NAME,
            "samesite": "strict",
            "httponly": True,
            "secure": getattr(settings, "ENVIRONMENT", "development") == "production"
        }
    })
    
    # Definir cookie CSRF
    response.set_cookie(
        key=CSRF_COOKIE_NAME,
        value=token,
        max_age=3600,
        secure=getattr(settings, "ENVIRONMENT", "development") == "production",
        httponly=True,
        samesite="strict",
        path="/"
    )
    
    return response


@app.get("/security-info", tags=["Segurança"])
async def security_info(request: Request):
    """🛡️ Informações de Segurança"""
    return JSONResponse(content={
        "security_features": {
            "csrf_protection": {
                "enabled": True,
                "cookie_name": CSRF_COOKIE_NAME,
                "header_name": CSRF_HEADER_NAME,
                "samesite": "strict",
                "max_age": 3600
            },
            "security_headers": {
                "csp": "✅ Enabled",
                "hsts": "✅ Enabled",
                "x_frame_options": "✅ DENY"
            },
            "rate_limiting": {
                "global": "300/min",
                "login": "10/min"
            }
        },
        "endpoints": {
            "get_csrf_token": "/csrf-token",
            "csp_report": "/csp-report"
        }
    })


# Importar constantes CSRF
from app.core.csrf_protection import CSRF_COOKIE_NAME, CSRF_HEADER_NAME


@app.get("/rate-limit-info", tags=["Sistema"])
@limiter.limit("300/minute")
async def rate_limit_info(request: Request):
    """📊 Informações de Rate Limit"""
    from app.core.rate_limit import get_rate_limit_info
    
    return JSONResponse(content={
        "global_limit": "300 requisições por minuto",
        "login_limit": "10 requisições por minuto",
        "strategy": "fixed-window",
        "identifier": "IP ou User ID",
        "current_info": get_rate_limit_info(request),
        "exemptions": [
            "/health",
            "/docs",
            "/redoc",
            "/openapi.json"
        ]
    })

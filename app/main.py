from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.database import init_db
from app.routers import auth_router, entidades_router, cameras, contratos
from app.core.config import settings
from app.core.rate_limit import limiter, rate_limit_exceeded_handler, exempt_from_rate_limit

init_db()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="""
    🛡️ **Sentinela** - Sistema de Autenticação e Controle de Acesso
    
    **Validações de Segurança:**
    - ✅ JWT (JSON Web Tokens)
    - ✅ MFA TOTP (Multi-Factor Authentication) - Obrigatório para ROOT/GESTOR
    - ✅ RBAC (Role-Based Access Control)
    - ✅ Validação de Entidade Ativa em todas as rotas (exceto /auth)
    - ✅ Rate Limiting: 300 requisições/minuto (global)
    
    **Níveis de Acesso:**
    - 🔓 **Público**: `/`, `/health`, `/docs`
    - 🔐 **Autenticação**: `/auth/*`
    - 🔒 **Autenticação + Entidade Ativa**: Todas as outras rotas
    """
)

# ============ Middlewares ============

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate Limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)


# ============ Middleware de Isenção de Rate Limit ============

@app.middleware("http")
async def rate_limit_exemption_middleware(request: Request, call_next):
    """
    Middleware para aplicar isenções de rate limit
    """
    # Verificar se deve ser isento
    if exempt_from_rate_limit(request):
        # Pular rate limiting
        response = await call_next(request)
        return response
    
    # Continuar normalmente (rate limiting aplicado pelos decorators)
    response = await call_next(request)
    return response


# ============ Registrar Routers ============

# 🔐 Rotas de Autenticação (SEM require_active_entidade)
app.include_router(auth_router.router)

# 🔒 Rotas de Entidades (COM require_active_entidade seletiva)
app.include_router(entidades_router.router)

# 🔒 Rotas de Câmeras (COM require_active_entidade)
app.include_router(cameras.router)

# 🔒 Rotas de Contratos (COM require_active_entidade)
app.include_router(contratos.router)


# ============ Rotas Públicas ============

@app.get("/", tags=["Sistema"])
@limiter.limit("300/minute")
async def root(request: Request):
    """🏠 Rota raiz - Informações do sistema"""
    return JSONResponse(content={
        "app": settings.APP_NAME,
        "version": settings.VERSION,
        "docs": "/docs",
        "security": {
            "jwt": "✅ Enabled",
            "mfa_totp": "✅ Required for ROOT/GESTOR",
            "entidade_validation": "✅ Active on all routes (except /auth)",
            "rate_limiting": "✅ 300 req/min (global)"
        },
        "endpoints": {
            "auth": "/auth",
            "entidades": "/entidades",
            "cameras": "/cameras",
            "contratos": "/contratos"
        }
    })


@app.get("/health", tags=["Sistema"])
async def health(request: Request):
    """
    💚 Health check - Status do sistema
    
    Isento de rate limiting
    """
    return JSONResponse(content={
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.VERSION,
        "rate_limiting": {
            "enabled": True,
            "limit": "300 req/min"
        }
    })


@app.get("/rate-limit-info", tags=["Sistema"])
@limiter.limit("300/minute")
async def rate_limit_info(request: Request):
    """
    📊 Informações de Rate Limit
    
    Retorna informações sobre os limites aplicados
    """
    from app.core.rate_limit import get_rate_limit_info
    
    return JSONResponse(content={
        "global_limit": "300 requisições por minuto",
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

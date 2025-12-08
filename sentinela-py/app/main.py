"""
Sentinela - Sistema de Monitoramento de Contratos Públicos
Aplicação principal FastAPI com lifespan management
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1 import auth, entidades, fornecedores, contratos, pncp


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Gerenciamento do ciclo de vida da aplicação.
    Inicialização e limpeza de recursos.
    """
    # Startup: inicializar conexões, cache, etc.
    print("🚀 Sentinela iniciando...")
    yield
    # Shutdown: fechar conexões, limpar recursos
    print("👋 Sentinela encerrando...")


# Inicialização da aplicação FastAPI
app = FastAPI(
    title="Sentinela API",
    description="Vigilância total, risco zero. API de monitoramento de contratos públicos.",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configuração de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registro de rotas
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Autenticação"])
app.include_router(entidades.router, prefix="/api/v1/entidades", tags=["Entidades"])
app.include_router(fornecedores.router, prefix="/api/v1/fornecedores", tags=["Fornecedores"])
app.include_router(contratos.router, prefix="/api/v1/contratos", tags=["Contratos"])
app.include_router(pncp.router, prefix="/api/v1/pncp", tags=["PNCP"])


@app.get("/")
async def root():
    """Endpoint raiz - health check"""
    return {
        "message": "Sentinela API",
        "status": "online",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """Verificação de saúde da aplicação"""
    return {
        "status": "healthy",
        "database": "connected",
        "cache": "ready"
    }

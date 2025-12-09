"""
Configurações da aplicação
Usa variáveis de ambiente com valores padrão

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
from os import getenv
from pathlib import Path

# Diretório base do projeto
BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Settings:
    """
    Classe de configurações da aplicação
    
    Todas as configurações podem ser sobrescritas via variáveis de ambiente.
    """
    
    # ============ Aplicação ============
    APP_NAME: str = getenv("APP_NAME", "Sistema Sentinela")
    VERSION: str = getenv("VERSION", "1.0.0")
    DEBUG: bool = getenv("DEBUG", "false").lower() == "true"
    ENVIRONMENT: str = getenv("ENVIRONMENT", "development")
    
    # ============ Segurança - JWT ============
    SECRET_KEY: str = getenv("SECRET_KEY", "your-secret-key-here-change-in-production-make-it-long-and-random")
    ALGORITHM: str = getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # ============ Segurança - Bcrypt ============
    BCRYPT_ROUNDS: int = int(getenv("BCRYPT_ROUNDS", "12"))
    
    # ============ Banco de Dados ============
    DATABASE_URL: str = getenv(
        "DATABASE_URL",
        f"sqlite:///{BASE_DIR}/sentinela.db"
    )
    
    # ============ Security Headers (Helmet) ============
    APP_DOMAIN: str = getenv("APP_DOMAIN", "sentinela.example.com")
    ENABLE_HSTS: bool = getenv("ENABLE_HSTS", "true").lower() == "true"
    
    # ============ Rate Limiting ============
    RATE_LIMIT_ENABLED: bool = getenv("RATE_LIMIT_ENABLED", "true").lower() == "true"
    RATE_LIMIT_GLOBAL: str = getenv("RATE_LIMIT_GLOBAL", "300/minute")
    RATE_LIMIT_LOGIN: str = getenv("RATE_LIMIT_LOGIN", "10/minute")
    
    # ============ CSRF Protection ============
    CSRF_ENABLED: bool = getenv("CSRF_ENABLED", "true").lower() == "true"
    CSRF_TOKEN_MAX_AGE: int = int(getenv("CSRF_TOKEN_MAX_AGE", "3600"))
    
    # ============ Logging ============
    LOG_LEVEL: str = getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = getenv("LOG_FILE", str(BASE_DIR / "logs" / "sentinela.log"))
    
    # ============ CORS ============
    CORS_ORIGINS: list = getenv("CORS_ORIGINS", "*").split(",")
    
    def __repr__(self):
        """Representação string segura (sem expor SECRET_KEY)"""
        return (
            f"Settings("
            f"APP_NAME={self.APP_NAME}, "
            f"VERSION={self.VERSION}, "
            f"ENVIRONMENT={self.ENVIRONMENT}, "
            f"DEBUG={self.DEBUG}"
            f")"
        )


# Instância global de configurações
settings = Settings()


# ============ Validação de Configurações ============

def validate_settings():
    """
    Valida configurações críticas
    
    Raises:
        ValueError: Se alguma configuração crítica estiver inválida
    """
    # Validar SECRET_KEY em produção
    if settings.ENVIRONMENT == "production":
        if settings.SECRET_KEY == "your-secret-key-here-change-in-production-make-it-long-and-random":
            raise ValueError(
                "🚨 ERRO CRÍTICO: SECRET_KEY padrão detectada em produção! "
                "Defina uma SECRET_KEY segura via variável de ambiente."
            )
        
        if len(settings.SECRET_KEY) < 32:
            raise ValueError(
                "🚨 ERRO CRÍTICO: SECRET_KEY muito curta em produção! "
                "Use pelo menos 32 caracteres."
            )
        
        if not settings.ENABLE_HSTS:
            import warnings
            warnings.warn(
                "⚠️  AVISO: HSTS desabilitado em produção. "
                "Recomendado habilitar para segurança."
            )
    
    # Validar BCRYPT_ROUNDS
    if settings.BCRYPT_ROUNDS < 10:
        import warnings
        warnings.warn(
            f"⚠️  AVISO: BCRYPT_ROUNDS muito baixo ({settings.BCRYPT_ROUNDS}). "
            f"Recomendado: >= 12"
        )
    
    if settings.BCRYPT_ROUNDS > 20:
        import warnings
        warnings.warn(
            f"⚠️  AVISO: BCRYPT_ROUNDS muito alto ({settings.BCRYPT_ROUNDS}). "
            f"Pode causar lentidão. Recomendado: 12-15"
        )


# Executar validação ao importar (apenas warning, não bloqueia)
try:
    validate_settings()
except ValueError as e:
    # Em produção, erro crítico bloqueia execução
    if settings.ENVIRONMENT == "production":
        raise
    else:
        # Em desenvolvimento, apenas avisa
        import warnings
        warnings.warn(str(e))

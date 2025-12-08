"""
Configurações da aplicação usando Pydantic Settings.
Gerenciamento de variáveis de ambiente e configurações globais.
"""

from typing import List
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Configurações principais da aplicação Sentinela.
    Todas as variáveis podem ser sobrescritas via arquivo .env
    """
    
    # Configurações gerais
    PROJECT_NAME: str = "Sentinela"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Segurança
    SECRET_KEY: str = "CHANGE-THIS-SECRET-KEY-IN-PRODUCTION"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:5173"]
    
    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: str | List[str]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)
    
    # Database (PostgreSQL via Neon)
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/sentinela"
    
    # Redis (para cache e Celery)
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Celery
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"
    
    # AWS S3 (para backups)
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_REGION: str = "us-east-1"
    S3_BUCKET_NAME: str = "sentinela-backups"
    
    # PNCP API
    PNCP_API_BASE_URL: str = "https://pncp.gov.br/api"
    PNCP_API_TIMEOUT: int = 30
    
    # MFA/TOTP
    MFA_ISSUER_NAME: str = "Sentinela"
    
    # Logs
    LOG_LEVEL: str = "INFO"
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True
    )


# Instância global de configurações
settings = Settings()

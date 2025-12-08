"""
Configurações da aplicação
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import Optional


class Settings(BaseSettings):
    """Configurações do sistema Sentinela"""
    
    # JWT Configuration
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Database
    DATABASE_URL: str = "sqlite:///./sentinela.db"
    
    # App
    APP_NAME: str = "Sentinela"
    DEBUG: bool = False
    VERSION: str = "1.0.0"
    
    # Security
    BCRYPT_ROUNDS: int = 12
    MFA_WINDOW: int = 1  # Janela de tempo para TOTP (±30s)
    
    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """Retorna configurações em cache"""
    return Settings()


settings = get_settings()
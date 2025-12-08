#!/bin/bash

echo "🔧 Corrigindo e testando estrutura..."
echo "====================================="

# 1. Atualizar config.py
echo "📝 1. Atualizando app/core/config.py..."
cat > app/core/config.py << 'EOF'
from pydantic_settings import BaseSettings
from pydantic import ConfigDict
from functools import lru_cache
from typing import Literal

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
    DEBUG: bool = True
    VERSION: str = "1.0.0"
    ENVIRONMENT: Literal["development", "production", "testing"] = "development"
    
    # Security
    BCRYPT_ROUNDS: int = 12
    MFA_WINDOW: int = 1
    
    model_config = ConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )

@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
EOF

# 2. Garantir .env correto
echo "📝 2. Verificando .env..."
if ! grep -q "BCRYPT_ROUNDS" .env; then
    echo "BCRYPT_ROUNDS=12" >> .env
fi
if ! grep -q "MFA_WINDOW" .env; then
    echo "MFA_WINDOW=1" >> .env
fi

# 3. Limpar cache
echo "🧹 3. Limpando cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
rm -rf .pytest_cache 2>/dev/null || true

# 4. Testar configuração
echo "🧪 4. Testando configuração..."
python3 << 'PYEOF'
try:
    from app.core.config import settings
    print(f"✅ JWT_SECRET_KEY: {settings.JWT_SECRET_KEY[:20]}...")
    print(f"✅ BCRYPT_ROUNDS: {settings.BCRYPT_ROUNDS}")
    print(f"✅ MFA_WINDOW: {settings.MFA_WINDOW}")
except Exception as e:
    print(f"❌ Erro: {e}")
    exit(1)
PYEOF

# 5. Executar testes
echo ""
echo "🚀 5. Executando testes..."
echo "====================================="
pytest tests/test_dependencies.py -v


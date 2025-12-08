# Teste se o .env está correto
cat .env

# Teste os imports
python3 << 'EOF'
print("🧪 Testando configuração...")
try:
    from app.core.config import settings
    print(f"✅ JWT_SECRET_KEY: {settings.JWT_SECRET_KEY[:20]}...")
    print(f"✅ DATABASE_URL: {settings.DATABASE_URL}")
    print(f"✅ APP_NAME: {settings.APP_NAME}")
    print("✅ Config OK!")
except Exception as e:
    print(f"❌ Erro: {e}")
EOF
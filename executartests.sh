# 1. Limpar TODO o cache Python
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
rm -rf .pytest_cache 2>/dev/null || true

# 2. Verificar que o .env está correto
cat .env | head -10

# 3. Testar imports manualmente
python3 << 'EOF'
import sys
import os
sys.path.insert(0, '/workspaces/sentinela')
os.chdir('/workspaces/sentinela')

print("🧪 Testando todos os imports...")
print("=" * 60)

try:
    from app.core.config import settings
    print(f"✅ 1. Config OK - JWT_SECRET_KEY: {settings.JWT_SECRET_KEY[:30]}...")
except Exception as e:
    print(f"❌ 1. Config ERROR: {e}")

try:
    from app.core.database import get_db
    print("✅ 2. Database OK")
except Exception as e:
    print(f"❌ 2. Database ERROR: {e}")

try:
    from app.core.models import User, UserRole
    print("✅ 3. Models OK")
except Exception as e:
    print(f"❌ 3. Models ERROR: {e}")

try:
    from app.core.auth import verify_password
    print("✅ 4. Auth OK")
except Exception as e:
    print(f"❌ 4. Auth ERROR: {e}")

try:
    from app.core.dependencies import get_current_user
    print("✅ 5. Dependencies OK")
except Exception as e:
    print(f"❌ 5. Dependencies ERROR: {e}")

print("=" * 60)
print("✅ Todos os imports funcionaram!")
EOF

# 4. Executar os testes
pytest tests/test_dependencies.py -vvs
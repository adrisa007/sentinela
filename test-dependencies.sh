#!/bin/bash

echo "🧪 Testando app.core.dependencies"
echo "=================================="
echo ""

# Limpar
echo "🧹 Limpando cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
rm -rf .pytest_cache
rm -f test.db

# Verificar imports
echo ""
echo "🔍 Verificando imports disponíveis..."
python << 'EOF'
from app.core.dependencies import (
    get_current_user,
    require_role,
    require_root,
    require_gestor,
    CurrentUser,
    decode_jwt_token
)
print("✅ Todos os imports principais OK")
EOF

# Executar testes
echo ""
echo "🚀 Executando testes..."
echo "=================================="
python -m pytest tests/test_dependencies.py -v --tb=short

echo ""
echo "=================================="
echo "✅ Testes concluídos!"


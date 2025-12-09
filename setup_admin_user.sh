#!/bin/bash
# setup_admin_user.sh
# Cria usuário admin inicial para adrisa007/sentinela (ID: 1112237272)

echo "👤 Criando Usuário Admin - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

# 1. Criar script Python para adicionar usuário admin
cat > create_admin.py << 'PYSCRIPT'
"""
Script para criar usuário admin inicial
Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import os
import sys
from datetime import datetime

# Adicionar path do app
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal, engine, Base
from app.models.user import User
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_admin_user():
    """Cria usuário admin inicial"""
    db = SessionLocal()
    
    try:
        # Verificar se admin já existe
        existing_admin = db.query(User).filter(User.username == "admin").first()
        
        if existing_admin:
            print("✅ Usuário admin já existe!")
            print(f"   Username: {existing_admin.username}")
            print(f"   Email: {existing_admin.email}")
            print(f"   Role: {existing_admin.role}")
            return
        
        # Criar tabelas se não existirem
        Base.metadata.create_all(bind=engine)
        
        # Criar usuário admin
        admin_user = User(
            username="admin",
            email="admin@sentinela.com",
            hashed_password=pwd_context.hash("admin123"),
            role="ROOT",
            is_active=True,
            mfa_enabled=False,  # Desabilitado inicialmente
            totp_secret=None,
            created_at=datetime.utcnow(),
        )
        
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print("✅ Usuário admin criado com sucesso!")
        print("")
        print("📋 Credenciais:")
        print("   Username: admin")
        print("   Email: admin@sentinela.com")
        print("   Password: admin123")
        print("   Role: ROOT")
        print("")
        print("⚠️  IMPORTANTE: Altere a senha após o primeiro login!")
        
    except Exception as e:
        print(f"❌ Erro ao criar usuário admin: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    create_admin_user()
PYSCRIPT

echo "✓ create_admin.py criado"

# 2. Executar script para criar admin
echo ""
echo "🔧 Executando criação do usuário admin..."
python3 create_admin.py

echo ""

# 3. Testar login com as credenciais corretas
echo "🧪 Testando login via API..."
echo ""

RESPONSE=$(curl -s -X POST https://web-production-8355.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

echo "Resposta do backend:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"

# Verificar se login foi bem-sucedido
if echo "$RESPONSE" | grep -q "token"; then
    echo ""
    echo "✅ Login bem-sucedido!"
    
    # Extrair token
    TOKEN=$(echo "$RESPONSE" | jq -r '.token' 2>/dev/null)
    
    if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
        echo ""
        echo "🔑 Token JWT recebido:"
        echo "$TOKEN" | cut -c1-50
        echo "..."
        
        # Testar endpoint protegido
        echo ""
        echo "🧪 Testando endpoint protegido (/auth/me)..."
        curl -s https://web-production-8355.up.railway.app/auth/me \
          -H "Authorization: Bearer $TOKEN" | jq '.' 2>/dev/null
    fi
else
    echo ""
    echo "⚠️  Login falhou. Verifique as credenciais."
fi

echo ""
echo "================================================================"
echo "📚 DOCUMENTAÇÃO DA API"
echo "================================================================"
echo ""
echo "🌐 URLs disponíveis:"
echo ""
echo "  Swagger UI (interativo):"
echo "  https://web-production-8355.up.railway.app/docs"
echo ""
echo "  ReDoc (alternativo):"
echo "  https://web-production-8355.up.railway.app/redoc"
echo ""
echo "  OpenAPI JSON:"
echo "  https://web-production-8355.up.railway.app/openapi.json"
echo ""
echo "💡 Para abrir no navegador:"
echo ""

# Detectar sistema operacional
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  open https://web-production-8355.up.railway.app/docs"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  xdg-open https://web-production-8355.up.railway.app/docs"
else
    echo "  Copie e cole no navegador:"
    echo "  https://web-production-8355.up.railway.app/docs"
fi

echo ""
echo "================================================================"
echo "🔐 CREDENCIAIS DE TESTE"
echo "================================================================"
echo ""
echo "Username: admin"
echo "Email: admin@sentinela.com"
echo "Password: admin123"
echo "Role: ROOT"
echo ""
echo "🚀 Testar no Frontend Local:"
echo "  cd frontend"
echo "  npm run dev"
echo "  http://localhost:3000/login"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
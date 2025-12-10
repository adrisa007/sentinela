"""
Script para criar usuário de teste para PNCP
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.core.models import User, Entidade, UserRole, TipoEntidade
from passlib.context import CryptContext
from datetime import datetime

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

db = SessionLocal()

try:
    # Verificar se usuário já existe
    existing = db.query(User).filter(User.username == "teste").first()
    if existing:
        print(f"✅ Usuário 'teste' já existe (ID: {existing.id})")
    else:
        # Criar entidade de teste
        entidade = Entidade(
            nome="Entidade Teste",
            cnpj="12345678000190",
            tipo=TipoEntidade.EMPRESA,
            is_active=True
        )
        db.add(entidade)
        db.flush()
        
        # Criar usuário
        # Hash pré-gerado de "senha123"
        hashed_pass = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5eLW5S7NRaJuS"
        user = User(
            username="teste",
            email="teste@sentinela.com",
            hashed_password=hashed_pass,
            role=UserRole.GESTOR,
            entidade_id=entidade.id,
            is_active=True,
            mfa_enabled=False
        )
        db.add(user)
        db.commit()
        print(f"✅ Usuário 'teste' criado com sucesso! (ID: {user.id})")
    
    print("\n📝 Credenciais:")
    print("   Username: teste")
    print("   Password: senha123")
    print("   Role: GESTOR")
    
except Exception as e:
    print(f"❌ Erro: {e}")
    db.rollback()
finally:
    db.close()

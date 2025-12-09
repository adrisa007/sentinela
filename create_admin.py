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

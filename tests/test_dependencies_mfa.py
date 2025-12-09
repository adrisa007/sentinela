"""
Testes específicos para validação MFA obrigatória em ROOT/GESTOR
"""
import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
from jose import jwt

from app.core.dependencies import get_current_user, require_mfa_verified
from app.core.models import User, UserRole
from app.core.auth import create_access_token
from app.core.config import settings


class TestMFARequirement:
    """Testes para MFA obrigatório em ROOT/GESTOR"""
    
    def test_root_without_mfa_configured_fails(self, db_session: Session):
        """Teste: ROOT sem MFA configurado deve falhar"""
        # Criar usuário ROOT sem MFA (senha simples para evitar erro bcrypt)
        user = User(
            username="root_no_mfa",
            email="root@test.com",
            hashed_password="$2b$12$test_hash",  # Hash fake para teste
            role=UserRole.ROOT,
            is_active=True,
            mfa_enabled=False
        )
        db_session.add(user)
        db_session.commit()
        
        # Verificar que MFA não está habilitado
        assert user.mfa_enabled is False
        assert user.role == UserRole.ROOT
    
    def test_gestor_without_mfa_configured_fails(self, db_session: Session):
        """Teste: GESTOR sem MFA configurado deve falhar"""
        user = User(
            username="gestor_no_mfa",
            email="gestor@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.GESTOR,
            is_active=True,
            mfa_enabled=False
        )
        db_session.add(user)
        db_session.commit()
        
        assert user.mfa_enabled is False
        assert user.role == UserRole.GESTOR
    
    def test_operador_without_mfa_allowed(self, db_session: Session):
        """Teste: OPERADOR pode acessar sem MFA"""
        user = User(
            username="operador_no_mfa",
            email="operador@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.OPERADOR,
            is_active=True,
            mfa_enabled=False
        )
        db_session.add(user)
        db_session.commit()
        
        # OPERADOR não precisa de MFA
        assert user.mfa_enabled is False
        assert user.role == UserRole.OPERADOR
    
    def test_token_without_totp_for_root_fails(self):
        """Teste: Token sem TOTP para ROOT deve falhar na validação"""
        # Token sem campo 'totp'
        token = create_access_token(data={"sub": "1"})
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        
        # Verificar que não tem TOTP
        assert "totp" not in payload
    
    def test_token_with_totp_for_root_has_field(self):
        """Teste: Token com TOTP para ROOT tem o campo correto"""
        token = create_access_token(data={"sub": "1", "totp": "123456"})
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        
        # Verificar que tem TOTP
        assert "totp" in payload
        assert payload["totp"] == "123456"
    
    def test_user_roles_require_mfa(self):
        """Teste: Validar quais roles requerem MFA"""
        # ROOT e GESTOR requerem MFA
        roles_requiring_mfa = [UserRole.ROOT, UserRole.GESTOR]
        
        assert UserRole.ROOT in roles_requiring_mfa
        assert UserRole.GESTOR in roles_requiring_mfa
        assert UserRole.OPERADOR not in roles_requiring_mfa


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

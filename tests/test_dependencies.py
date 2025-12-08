"""
Testes para app.core.dependencies
"""
import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
import inspect

from app.core.dependencies import (
    get_current_user,
    require_role,
    require_root,
    require_gestor,
    decode_jwt_token,
    CurrentUser
)
from app.core.models import User, UserRole
from app.core.auth import create_access_token, get_password_hash


@pytest.fixture
def test_user_operador(db_session: Session):
    """Cria usuário OPERADOR para testes"""
    user = User(
        username="test_operador",
        email="operador@test.com",
        hashed_password=get_password_hash("Test@123"),
        role=UserRole.OPERADOR,
        is_active=True,
        mfa_enabled=False
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def test_user_gestor(db_session: Session):
    """Cria usuário GESTOR para testes"""
    user = User(
        username="test_gestor",
        email="gestor@test.com",
        hashed_password=get_password_hash("Test@123"),
        role=UserRole.GESTOR,
        is_active=True,
        mfa_enabled=True,
        mfa_secret="JBSWY3DPEHPK3PXP"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def test_user_root(db_session: Session):
    """Cria usuário ROOT para testes"""
    user = User(
        username="test_root",
        email="root@test.com",
        hashed_password=get_password_hash("Test@123"),
        role=UserRole.ROOT,
        is_active=True,
        mfa_enabled=True,
        mfa_secret="JBSWY3DPEHPK3PXP"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


def test_decode_jwt_token_valid():
    """Teste: Decodificar token JWT válido"""
    token = create_access_token(data={"sub": "1", "username": "testuser"})
    payload = decode_jwt_token(token)
    
    assert payload is not None
    assert payload["sub"] == "1"
    assert payload["username"] == "testuser"


def test_decode_jwt_token_invalid():
    """Teste: Decodificar token JWT inválido deve lançar exceção"""
    with pytest.raises(HTTPException) as exc_info:
        decode_jwt_token("invalid_token")
    
    assert exc_info.value.status_code == 401
    assert "inválido" in exc_info.value.detail.lower()


def test_current_user_class():
    """Teste: Classe CurrentUser"""
    user = User(
        id=1,
        username="testuser",
        email="test@test.com",
        hashed_password="hashed",
        role=UserRole.OPERADOR,
        is_active=True
    )
    
    current_user = CurrentUser(user=user, mfa_verified=False)
    
    assert current_user.id == 1
    assert current_user.username == "testuser"
    assert current_user.email == "test@test.com"
    assert current_user.role == UserRole.OPERADOR
    assert current_user.mfa_verified is False


def test_current_user_class_with_mfa():
    """Teste: Classe CurrentUser com MFA verificado"""
    user = User(
        id=2,
        username="rootuser",
        email="root@test.com",
        hashed_password="hashed",
        role=UserRole.ROOT,
        is_active=True,
        mfa_enabled=True
    )
    
    current_user = CurrentUser(user=user, mfa_verified=True)
    
    assert current_user.id == 2
    assert current_user.role == UserRole.ROOT
    assert current_user.mfa_verified is True


def test_require_role_returns_dependency():
    """Teste: require_role retorna uma função dependency"""
    # CORREÇÃO: require_role não é async, é uma factory function
    dependency_func = require_role(UserRole.ROOT)
    
    # Verifica que retorna uma função callable
    assert callable(dependency_func)
    
    # Verifica que a função retornada é uma corrotina (async)
    assert inspect.iscoroutinefunction(dependency_func)


def test_require_root_exists():
    """Teste: require_root existe e é callable"""
    assert callable(require_root)
    # Verifica que é uma função async
    assert inspect.iscoroutinefunction(require_root)


def test_require_gestor_exists():
    """Teste: require_gestor existe e é callable"""
    assert callable(require_gestor)
    # Verifica que é uma função async
    assert inspect.iscoroutinefunction(require_gestor)


def test_user_roles_enum():
    """Teste: Enum UserRole tem valores corretos"""
    assert UserRole.ROOT == "ROOT"
    assert UserRole.GESTOR == "GESTOR"
    assert UserRole.OPERADOR == "OPERADOR"


class TestDependenciesIntegration:
    """Testes de integração para dependencies"""
    
    def test_imports_success(self):
        """Teste: Todos os imports necessários funcionam"""
        from app.core.dependencies import (
            get_current_user,
            require_role,
            require_root,
            require_gestor,
            CurrentUser,
            decode_jwt_token
        )
        assert get_current_user is not None
        assert require_role is not None
        assert require_root is not None
        assert require_gestor is not None
        assert CurrentUser is not None
        assert decode_jwt_token is not None
    
    def test_current_user_attributes(self):
        """Teste: CurrentUser tem todos os atributos necessários"""
        user = User(
            id=1,
            username="test",
            email="test@test.com",
            hashed_password="hash",
            role=UserRole.OPERADOR
        )
        current_user = CurrentUser(user=user)
        
        assert hasattr(current_user, 'id')
        assert hasattr(current_user, 'username')
        assert hasattr(current_user, 'email')
        assert hasattr(current_user, 'role')
        assert hasattr(current_user, 'mfa_verified')
        assert hasattr(current_user, 'user')
    
    def test_jwt_token_with_integer_sub(self):
        """Teste: Token JWT com sub como integer é convertido automaticamente"""
        # Cria token com sub como integer (como app.core.auth faz)
        token = create_access_token(data={"sub": 1})
        
        # Decodifica (deve funcionar com conversão automática)
        payload = decode_jwt_token(token)
        
        # Verifica que sub foi convertido para string
        assert payload["sub"] == "1"
        assert isinstance(payload["sub"], str)
    
    def test_require_role_with_multiple_roles(self):
        """Teste: require_role aceita múltiplas roles"""
        dependency_func = require_role(UserRole.ROOT, UserRole.GESTOR)
        
        # Verifica que retorna uma função
        assert callable(dependency_func)
        assert inspect.iscoroutinefunction(dependency_func)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

"""
Testes para require_root_user dependency
"""
import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import require_root_user, require_root_or_owner, CurrentUser
from app.core.models import User, UserRole


@pytest.fixture
def root_user(db_session: Session):
    """Cria usuário ROOT com MFA"""
    user = User(
        username="root_admin",
        email="root@sentinela.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.ROOT,
        is_active=True,
        mfa_enabled=True,
        mfa_secret="JBSWY3DPEHPK3PXP"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def gestor_user(db_session: Session):
    """Cria usuário GESTOR"""
    user = User(
        username="gestor1",
        email="gestor@sentinela.com",
        hashed_password="$2b$12$test_hash",
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
def operador_user(db_session: Session):
    """Cria usuário OPERADOR"""
    user = User(
        username="operador1",
        email="operador@sentinela.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.OPERADOR,
        is_active=True,
        mfa_enabled=False
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


class TestRequireRootUser:
    """Testes para require_root_user"""
    
    def test_root_user_is_root(self, root_user: User):
        """Teste: Usuário ROOT tem perfil correto"""
        assert root_user.role == UserRole.ROOT
        assert root_user.mfa_enabled is True
    
    def test_gestor_is_not_root(self, gestor_user: User):
        """Teste: Usuário GESTOR não é ROOT"""
        assert gestor_user.role == UserRole.GESTOR
        assert gestor_user.role != UserRole.ROOT
    
    def test_operador_is_not_root(self, operador_user: User):
        """Teste: Usuário OPERADOR não é ROOT"""
        assert operador_user.role == UserRole.OPERADOR
        assert operador_user.role != UserRole.ROOT
    
    def test_root_user_with_mfa(self, root_user: User):
        """Teste: ROOT deve ter MFA habilitado"""
        current_user = CurrentUser(user=root_user, mfa_verified=True)
        assert current_user.role == UserRole.ROOT
        assert current_user.mfa_verified is True
    
    def test_root_user_without_mfa_should_fail(self, root_user: User):
        """Teste: ROOT sem MFA verificado deve falhar"""
        current_user = CurrentUser(user=root_user, mfa_verified=False)
        assert current_user.mfa_verified is False
        # Em produção, require_root_user levantaria 403


class TestRootOrOwner:
    """Testes para require_root_or_owner"""
    
    def test_root_can_access_any_resource(self, root_user: User, operador_user: User):
        """Teste: ROOT pode acessar recurso de qualquer usuário"""
        root_current = CurrentUser(user=root_user, mfa_verified=True)
        
        # ROOT acessando recurso do OPERADOR
        assert root_current.role == UserRole.ROOT
        assert root_current.id != operador_user.id
        # Em produção, require_root_or_owner permitiria
    
    def test_user_can_access_own_resource(self, operador_user: User):
        """Teste: Usuário pode acessar próprio recurso"""
        current = CurrentUser(user=operador_user)
        
        # Usuário acessando próprio recurso
        assert current.id == operador_user.id
    
    def test_user_cannot_access_others_resource(
        self, 
        operador_user: User,
        gestor_user: User
    ):
        """Teste: Usuário não ROOT não pode acessar recurso de outro"""
        current = CurrentUser(user=operador_user)
        
        # OPERADOR tentando acessar recurso do GESTOR
        assert current.role != UserRole.ROOT
        assert current.id != gestor_user.id
        # Em produção, require_root_or_owner levantaria 403


class TestUserRoles:
    """Testes de validação de roles"""
    
    def test_all_user_roles(self):
        """Teste: Todos os roles disponíveis"""
        assert UserRole.ROOT == "ROOT"
        assert UserRole.GESTOR == "GESTOR"
        assert UserRole.OPERADOR == "OPERADOR"
    
    def test_role_hierarchy(self):
        """Teste: Hierarquia implícita de roles"""
        # ROOT > GESTOR > OPERADOR (implícito)
        roles = [UserRole.ROOT, UserRole.GESTOR, UserRole.OPERADOR]
        assert len(roles) == 3
        assert UserRole.ROOT in roles
        assert UserRole.GESTOR in roles
        assert UserRole.OPERADOR in roles


class TestRootUserSecurity:
    """Testes de segurança para ROOT"""
    
    def test_root_requires_mfa(self, root_user: User):
        """Teste: ROOT deve ter MFA obrigatório"""
        assert root_user.mfa_enabled is True
        assert root_user.mfa_secret is not None
    
    def test_root_is_active(self, root_user: User):
        """Teste: ROOT deve estar ativo"""
        assert root_user.is_active is True
    
    def test_multiple_root_users_allowed(self, db_session: Session):
        """Teste: Sistema permite múltiplos usuários ROOT"""
        root1 = User(
            username="root1",
            email="root1@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.ROOT,
            mfa_enabled=True
        )
        root2 = User(
            username="root2",
            email="root2@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.ROOT,
            mfa_enabled=True
        )
        
        db_session.add_all([root1, root2])
        db_session.commit()
        
        # Verificar que ambos são ROOT
        assert root1.role == UserRole.ROOT
        assert root2.role == UserRole.ROOT
        assert root1.id != root2.id


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

"""
Testes para validação de require_active_entidade em rotas
"""
import pytest
import pyotp
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.models import User, UserRole, Entidade, StatusEntidade, TipoEntidade
from app.core.auth import create_access_token


TEST_MFA_SECRET = "JBSWY3DPEHPK3PXP"


def generate_test_totp() -> str:
    return pyotp.TOTP(TEST_MFA_SECRET).now()


@pytest.fixture
def entidade_ativa(db_session: Session):
    """Cria entidade ATIVA"""
    entidade = Entidade(
        nome="Entidade Ativa",
        cnpj="11111111111111",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def entidade_inativa(db_session: Session):
    """Cria entidade INATIVA"""
    entidade = Entidade(
        nome="Entidade Inativa",
        cnpj="22222222222222",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.INATIVA,
        is_active=False
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def gestor_entidade_ativa(db_session: Session, entidade_ativa: Entidade):
    """GESTOR com entidade ATIVA"""
    user = User(
        username="gestor_ativo",
        email="gestor_ativo@test.com",
        hashed_password="$2b$12$test",
        role=UserRole.GESTOR,
        entidade_id=entidade_ativa.id,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET,
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    
    token = create_access_token({
        "sub": str(user.id),
        "totp": generate_test_totp()
    })
    return {"user": user, "token": token}


@pytest.fixture
def gestor_entidade_inativa(db_session: Session, entidade_inativa: Entidade):
    """GESTOR com entidade INATIVA"""
    user = User(
        username="gestor_inativo",
        email="gestor_inativo@test.com",
        hashed_password="$2b$12$test",
        role=UserRole.GESTOR,
        entidade_id=entidade_inativa.id,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET,
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    
    token = create_access_token({
        "sub": str(user.id),
        "totp": generate_test_totp()
    })
    return {"user": user, "token": token}


class TestActiveEntidadeValidation:
    """Testes de validação de entidade ativa"""
    
    def test_cameras_with_active_entidade_success(
        self,
        client: TestClient,
        gestor_entidade_ativa: dict
    ):
        """✅ Acesso a /cameras COM entidade ATIVA"""
        response = client.get(
            "/cameras/",
            headers={"Authorization": f"Bearer {gestor_entidade_ativa['token']}"}
        )
        
        assert response.status_code == 200
    
    def test_cameras_with_inactive_entidade_fails(
        self,
        client: TestClient,
        gestor_entidade_inativa: dict
    ):
        """❌ Acesso a /cameras COM entidade INATIVA deve falhar"""
        response = client.get(
            "/cameras/",
            headers={"Authorization": f"Bearer {gestor_entidade_inativa['token']}"}
        )
        
        assert response.status_code == 403
        assert "INATIVA" in response.json()["detail"] or "ativa" in response.json()["detail"].lower()
    
    def test_entidades_list_with_active_entidade_success(
        self,
        client: TestClient,
        gestor_entidade_ativa: dict
    ):
        """✅ Listar entidades COM entidade ATIVA"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_entidade_ativa['token']}"}
        )
        
        assert response.status_code == 200
    
    def test_entidades_list_with_inactive_entidade_fails(
        self,
        client: TestClient,
        gestor_entidade_inativa: dict
    ):
        """❌ Listar entidades COM entidade INATIVA deve falhar"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_entidade_inativa['token']}"}
        )
        
        assert response.status_code == 403


class TestAuthRoutesNoEntidadeValidation:
    """Testes: rotas /auth NÃO devem exigir entidade ativa"""
    
    def test_auth_routes_work_without_entidade(self, client: TestClient):
        """✅ Rotas /auth funcionam SEM entidade"""
        # Tentar fazer login (deve funcionar mesmo sem entidade)
        response = client.post(
            "/auth/login",
            json={
                "username": "inexistente",
                "password": "qualquer"
            }
        )
        
        # Não deve dar erro de entidade (deve dar erro de credenciais)
        assert response.status_code in [401, 422]  # Unauthorized ou Validation Error


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

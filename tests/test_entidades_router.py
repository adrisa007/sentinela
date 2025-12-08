"""
Testes para router de entidades com require_root_user
"""
import pytest
import pyotp
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.models import User, UserRole, Entidade, TipoEntidade, StatusEntidade
from app.core.auth import create_access_token


# Secret TOTP compartilhado para testes
TEST_MFA_SECRET = "JBSWY3DPEHPK3PXP"


def generate_test_totp() -> str:
    """Gera código TOTP válido para testes"""
    totp = pyotp.TOTP(TEST_MFA_SECRET)
    return totp.now()


@pytest.fixture
def root_entidade(db_session: Session):
    """Cria entidade para ROOT"""
    entidade = Entidade(
        nome="Entidade ROOT",
        cnpj="10000000000001",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def gestor_entidade(db_session: Session):
    """Cria entidade para GESTOR"""
    entidade = Entidade(
        nome="Entidade GESTOR",
        cnpj="20000000000002",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def operador_entidade(db_session: Session):
    """Cria entidade para OPERADOR"""
    entidade = Entidade(
        nome="Entidade OPERADOR",
        cnpj="30000000000003",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def root_user(db_session: Session, root_entidade: Entidade):
    """Cria usuário ROOT com entidade"""
    user = User(
        username="root_admin",
        email="root@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.ROOT,
        is_active=True,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET,
        entidade_id=root_entidade.id  # ✅ Associar entidade
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def root_token(root_user: User):
    """Retorna token JWT para usuário ROOT com código TOTP válido"""
    totp_code = generate_test_totp()
    token = create_access_token(
        data={"sub": str(root_user.id), "totp": totp_code}
    )
    return token


@pytest.fixture
def gestor_user(db_session: Session, gestor_entidade: Entidade):
    """Cria usuário GESTOR com entidade"""
    user = User(
        username="gestor1",
        email="gestor@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.GESTOR,
        is_active=True,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET,
        entidade_id=gestor_entidade.id  # ✅ Associar entidade
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def gestor_token(gestor_user: User):
    """Retorna token JWT para usuário GESTOR com código TOTP válido"""
    totp_code = generate_test_totp()
    token = create_access_token(
        data={"sub": str(gestor_user.id), "totp": totp_code}
    )
    return token


@pytest.fixture
def operador_user(db_session: Session, operador_entidade: Entidade):
    """Cria usuário OPERADOR com entidade"""
    user = User(
        username="operador1",
        email="operador@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.OPERADOR,
        is_active=True,
        entidade_id=operador_entidade.id  # ✅ Associar entidade
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def operador_token(operador_user: User):
    """Retorna token JWT para usuário OPERADOR"""
    token = create_access_token(data={"sub": str(operador_user.id)})
    return token


class TestCreateEntidadeRequireRoot:
    """Testes para POST /entidades com require_root_user"""
    
    def test_create_entidade_with_root_success(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: ROOT pode criar entidade"""
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa Teste",
                "razao_social": "Empresa Teste LTDA",
                "cnpj": "12345678901234",
                "tipo": "EMPRESA",
                "email": "contato@teste.com"
            }
        )
        
        assert response.status_code == 201, f"Response: {response.json()}"
        data = response.json()
        assert data["nome"] == "Empresa Teste"
        assert data["cnpj"] == "12345678901234"
    
    def test_create_entidade_with_gestor_fails(
        self,
        client: TestClient,
        gestor_token: str
    ):
        """Teste: GESTOR NÃO pode criar entidade (403 - perfil insuficiente)"""
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={
                "nome": "Empresa Teste",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code == 403
        detail = response.json()["detail"]
        assert "ROOT" in detail or "perfil" in detail.lower()
    
    def test_create_entidade_with_operador_fails(
        self,
        client: TestClient,
        operador_token: str
    ):
        """Teste: OPERADOR NÃO pode criar entidade"""
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {operador_token}"},
            json={
                "nome": "Empresa Teste",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code == 403
    
    def test_create_entidade_without_auth_fails(self, client: TestClient):
        """Teste: Sem autenticação não pode criar entidade"""
        response = client.post(
            "/entidades/",
            json={
                "nome": "Empresa Teste",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code in [401, 403]
    
    def test_create_entidade_duplicate_cnpj_fails(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: Não pode criar entidade com CNPJ duplicado"""
        # Criar primeira entidade
        first_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa 1",
                "cnpj": "99999999999999",
                "tipo": "EMPRESA"
            }
        )
        assert first_response.status_code == 201
        
        # Tentar criar segunda com mesmo CNPJ
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa 2",
                "cnpj": "99999999999999",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code == 400
        assert "CNPJ" in response.json()["detail"]


class TestListEntidades:
    """Testes para GET /entidades"""
    
    def test_list_entidades_root_success(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: ROOT pode listar entidades"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"}
        )
        
        assert response.status_code == 200
        assert isinstance(response.json(), list)
    
    def test_list_entidades_gestor_success(
        self,
        client: TestClient,
        gestor_token: str
    ):
        """Teste: GESTOR pode listar entidades"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_token}"}
        )
        
        assert response.status_code == 200
        assert isinstance(response.json(), list)
    
    def test_list_entidades_operador_fails(
        self,
        client: TestClient,
        operador_token: str
    ):
        """Teste: OPERADOR NÃO pode listar todas as entidades"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {operador_token}"}
        )
        
        assert response.status_code == 403


class TestEntidadesCRUD:
    """Testes de operações CRUD completas"""
    
    def test_full_entidade_lifecycle(
        self,
        client: TestClient,
        root_token: str,
        db_session: Session
    ):
        """Teste: Ciclo completo de vida de uma entidade"""
        
        # 1. Criar entidade
        create_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Ciclo Completo LTDA",
                "cnpj": "11111111111111",
                "tipo": "EMPRESA",
                "email": "ciclo@test.com"
            }
        )
        assert create_response.status_code == 201
        entidade_id = create_response.json()["id"]
        
        # 2. Listar e verificar que existe
        list_response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"}
        )
        assert list_response.status_code == 200
        entidades = list_response.json()
        assert any(e["id"] == entidade_id for e in entidades)
        
        # 3. Buscar por ID
        get_response = client.get(
            f"/entidades/{entidade_id}",
            headers={"Authorization": f"Bearer {root_token}"}
        )
        assert get_response.status_code == 200
        assert get_response.json()["id"] == entidade_id
        
        # 4. Atualizar
        update_response = client.put(
            f"/entidades/{entidade_id}",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"nome": "Ciclo Completo ATUALIZADO"}
        )
        assert update_response.status_code == 200
        assert "ATUALIZADO" in update_response.json()["nome"]
        
        # 5. Alterar status
        status_response = client.put(
            f"/entidades/{entidade_id}/status",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "status": "SUSPENSA",
                "motivo": "Teste de suspensão"
            }
        )
        assert status_response.status_code == 200
        
        # 6. Deletar
        delete_response = client.delete(
            f"/entidades/{entidade_id}",
            headers={"Authorization": f"Bearer {root_token}"}
        )
        assert delete_response.status_code == 200


class TestEntidadeMFAValidation:
    """Testes específicos de validação MFA"""
    
    def test_root_without_valid_totp_fails(
        self,
        client: TestClient,
        root_user: User
    ):
        """Teste: ROOT com código TOTP inválido falha"""
        invalid_token = create_access_token(
            data={"sub": str(root_user.id), "totp": "000000"}
        )
        
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {invalid_token}"},
            json={"nome": "Test", "tipo": "EMPRESA"}
        )
        
        assert response.status_code == 403
        assert "MFA" in response.json()["detail"] or "TOTP" in response.json()["detail"]
    
    def test_root_without_totp_in_token_fails(
        self,
        client: TestClient,
        root_user: User
    ):
        """Teste: ROOT sem código TOTP no token falha"""
        token_without_totp = create_access_token(data={"sub": str(root_user.id)})
        
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {token_without_totp}"},
            json={"nome": "Test", "tipo": "EMPRESA"}
        )
        
        assert response.status_code == 403
        assert "MFA" in response.json()["detail"]


class TestPatchEntidadeStatus:
    """Testes para PATCH /entidades/{id}/status com require_root_user"""
    
    def test_patch_status_with_root_success(
        self,
        client: TestClient,
        root_token: str,
        db_session: Session
    ):
        """Teste: ROOT pode alterar status via PATCH"""
        create_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa PATCH Test",
                "cnpj": "88888888888888",
                "tipo": "EMPRESA"
            }
        )
        assert create_response.status_code == 201
        entidade_id = create_response.json()["id"]
        
        patch_response = client.patch(
            f"/entidades/{entidade_id}/status",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "status": "INATIVA",
                "motivo": "Manutenção programada"
            }
        )
        
        assert patch_response.status_code == 200
    
    def test_patch_status_with_gestor_fails(
        self,
        client: TestClient,
        root_token: str,
        gestor_token: str
    ):
        """Teste: GESTOR NÃO pode alterar status via PATCH"""
        create_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa PATCH Gestor",
                "cnpj": "77777777777777",
                "tipo": "EMPRESA"
            }
        )
        entidade_id = create_response.json()["id"]
        
        patch_response = client.patch(
            f"/entidades/{entidade_id}/status",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={"status": "SUSPENSA", "motivo": "Teste"}
        )
        
        assert patch_response.status_code == 403
    
    def test_patch_status_operador_fails(
        self,
        client: TestClient,
        root_token: str,
        operador_token: str
    ):
        """Teste: OPERADOR NÃO pode alterar status via PATCH"""
        create_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa PATCH Operador",
                "cnpj": "66666666666666",
                "tipo": "EMPRESA"
            }
        )
        entidade_id = create_response.json()["id"]
        
        patch_response = client.patch(
            f"/entidades/{entidade_id}/status",
            headers={"Authorization": f"Bearer {operador_token}"},
            json={"status": "BLOQUEADA", "motivo": "Teste"}
        )
        
        assert patch_response.status_code == 403
    
    def test_patch_status_all_statuses(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: ROOT pode mudar para todos os status"""
        create_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Empresa Status Completo",
                "cnpj": "55555555555555",
                "tipo": "EMPRESA"
            }
        )
        entidade_id = create_response.json()["id"]
        
        statuses = ["INATIVA", "SUSPENSA", "BLOQUEADA", "EM_ANALISE", "ATIVA"]
        
        for new_status in statuses:
            response = client.patch(
                f"/entidades/{entidade_id}/status",
                headers={"Authorization": f"Bearer {root_token}"},
                json={"status": new_status, "motivo": f"Teste {new_status}"}
            )
            assert response.status_code == 200
    
    def test_patch_status_nonexistent_entidade_fails(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: PATCH em entidade inexistente retorna 404"""
        response = client.patch(
            "/entidades/999999/status",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"status": "INATIVA", "motivo": "Teste"}
        )
        
        assert response.status_code == 404
    
    def test_patch_vs_put_equivalence(
        self,
        client: TestClient,
        root_token: str
    ):
        """Teste: PATCH e PUT são funcionalmente equivalentes"""
        entity1 = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"nome": "Entidade PUT", "cnpj": "44444444444444", "tipo": "EMPRESA"}
        ).json()
        
        entity2 = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"nome": "Entidade PATCH", "cnpj": "33333333333333", "tipo": "EMPRESA"}
        ).json()
        
        put_response = client.put(
            f"/entidades/{entity1['id']}/status",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"status": "SUSPENSA", "motivo": "Via PUT"}
        )
        
        patch_response = client.patch(
            f"/entidades/{entity2['id']}/status",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"status": "SUSPENSA", "motivo": "Via PATCH"}
        )
        
        assert put_response.status_code == 200
        assert patch_response.status_code == 200


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

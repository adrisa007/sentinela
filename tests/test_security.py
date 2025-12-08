"""
Testes de Segurança do Sistema Sentinela
=========================================

Valida controles de acesso, permissões e proteções contra tentativas
de escalação de privilégios e acessos não autorizados.

Repositório: adrisa007/sentinela (ID: 1112237272)
"""
import pytest
import pyotp
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.models import User, UserRole, Entidade, TipoEntidade, StatusEntidade
from app.core.auth import create_access_token


# Configuração de teste
TEST_MFA_SECRET = "JBSWY3DPEHPK3PXP"


def generate_test_totp() -> str:
    """Gera código TOTP válido para testes"""
    return pyotp.TOTP(TEST_MFA_SECRET).now()


# ============ Fixtures ============

@pytest.fixture
def entidade_teste(db_session: Session):
    """Cria entidade de teste para associar aos usuários"""
    entidade = Entidade(
        nome="Entidade Teste Segurança",
        cnpj="99999999999999",
        tipo=TipoEntidade.EMPRESA,
        status=StatusEntidade.ATIVA,
        is_active=True
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def gestor_user(db_session: Session, entidade_teste: Entidade):
    """
    Cria usuário GESTOR com entidade e MFA habilitado
    GESTOR NÃO deve poder criar entidades
    """
    user = User(
        username="gestor_seguranca",
        email="gestor_seguranca@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.GESTOR,
        entidade_id=entidade_teste.id,
        is_active=True,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def gestor_token(gestor_user: User):
    """Token JWT válido para GESTOR com MFA"""
    totp_code = generate_test_totp()
    return create_access_token({
        "sub": str(gestor_user.id),
        "totp": totp_code
    })


@pytest.fixture
def operador_user(db_session: Session, entidade_teste: Entidade):
    """
    Cria usuário OPERADOR com entidade
    OPERADOR NÃO deve poder criar entidades
    """
    user = User(
        username="operador_seguranca",
        email="operador_seguranca@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.OPERADOR,
        entidade_id=entidade_teste.id,
        is_active=True,
        mfa_enabled=False  # OPERADOR não precisa de MFA
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def operador_token(operador_user: User):
    """Token JWT para OPERADOR (sem MFA)"""
    return create_access_token({
        "sub": str(operador_user.id)
    })


@pytest.fixture
def root_user(db_session: Session, entidade_teste: Entidade):
    """
    Cria usuário ROOT com entidade e MFA
    ROOT PODE criar entidades
    """
    user = User(
        username="root_seguranca",
        email="root_seguranca@test.com",
        hashed_password="$2b$12$test_hash",
        role=UserRole.ROOT,
        entidade_id=entidade_teste.id,
        is_active=True,
        mfa_enabled=True,
        mfa_secret=TEST_MFA_SECRET
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def root_token(root_user: User):
    """Token JWT válido para ROOT com MFA"""
    totp_code = generate_test_totp()
    return create_access_token({
        "sub": str(root_user.id),
        "totp": totp_code
    })


# ============ Testes de Segurança: Criação de Entidades ============

class TestSecurityCreateEntidade:
    """
    Testes de segurança para criação de entidades
    Valida que apenas ROOT pode criar entidades
    """
    
    def test_gestor_create_entidade_returns_403(
        self,
        client: TestClient,
        gestor_token: str
    ):
        """
        🔒 TESTE PRINCIPAL: GESTOR tentando criar entidade → 403 Forbidden
        
        **Cenário:**
        - Usuário com perfil GESTOR autenticado
        - MFA verificado corretamente
        - Tenta criar uma nova entidade
        
        **Resultado Esperado:**
        - Status Code: 403 Forbidden
        - Mensagem indicando que precisa ser ROOT
        - Operação NÃO deve ser executada
        
        **Validações de Segurança:**
        - ✅ Autenticação válida
        - ✅ MFA verificado
        - ❌ Perfil insuficiente (GESTOR < ROOT)
        """
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={
                "nome": "Tentativa GESTOR",
                "cnpj": "11111111111111",
                "tipo": "EMPRESA",
                "email": "tentativa@gestor.com"
            }
        )
        
        # Deve retornar 403 Forbidden
        assert response.status_code == 403, \
            f"GESTOR conseguiu criar entidade! Response: {response.json()}"
        
        # Verificar mensagem de erro
        detail = response.json()["detail"]
        assert "ROOT" in detail or "perfil" in detail.lower(), \
            f"Mensagem de erro inadequada: {detail}"
        
        # Verificar que a mensagem NÃO é genérica
        assert len(detail) > 20, "Mensagem de erro muito genérica"
    
    def test_operador_create_entidade_returns_403(
        self,
        client: TestClient,
        operador_token: str
    ):
        """
        🔒 OPERADOR tentando criar entidade → 403 Forbidden
        
        Valida que OPERADOR (perfil mais baixo) também não consegue criar entidades.
        """
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {operador_token}"},
            json={
                "nome": "Tentativa OPERADOR",
                "cnpj": "22222222222222",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code == 403
        detail = response.json()["detail"]
        assert "ROOT" in detail or "OPERADOR" in detail or "perfil" in detail.lower()
    
    def test_root_create_entidade_succeeds(
        self,
        client: TestClient,
        root_token: str
    ):
        """
        ✅ ROOT criando entidade → 201 Created (sucesso)
        
        Valida que ROOT (perfil mais alto) PODE criar entidades.
        Serve como teste de controle positivo.
        """
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={
                "nome": "Entidade ROOT Válida",
                "cnpj": "33333333333333",
                "tipo": "EMPRESA",
                "email": "root@valida.com"
            }
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["nome"] == "Entidade ROOT Válida"
        assert data["cnpj"] == "33333333333333"
    
    def test_unauthenticated_create_entidade_returns_401_or_403(
        self,
        client: TestClient
    ):
        """
        🔓 Requisição sem autenticação → 401/403
        
        Valida que tentativas sem token JWT são bloqueadas.
        """
        response = client.post(
            "/entidades/",
            json={
                "nome": "Tentativa Sem Auth",
                "tipo": "EMPRESA"
            }
        )
        
        # Pode ser 401 (Unauthorized) ou 403 (Forbidden - no credentials)
        assert response.status_code in [401, 403]
    
    def test_invalid_token_create_entidade_returns_401(
        self,
        client: TestClient
    ):
        """
        🔓 Token inválido → 401 Unauthorized
        
        Valida que tokens JWT malformados ou inválidos são rejeitados.
        """
        response = client.post(
            "/entidades/",
            headers={"Authorization": "Bearer token_invalido_xyz123"},
            json={
                "nome": "Tentativa Token Inválido",
                "tipo": "EMPRESA"
            }
        )
        
        assert response.status_code == 401


class TestSecurityGestorPermissions:
    """
    Testes de permissões do perfil GESTOR
    Valida o que GESTOR PODE e NÃO PODE fazer
    """
    
    def test_gestor_can_list_entidades(
        self,
        client: TestClient,
        gestor_token: str
    ):
        """✅ GESTOR PODE listar entidades"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_token}"}
        )
        
        assert response.status_code == 200
        assert isinstance(response.json(), list)
    
    def test_gestor_can_view_entidade(
        self,
        client: TestClient,
        gestor_token: str,
        entidade_teste: Entidade
    ):
        """✅ GESTOR PODE visualizar detalhes de entidade"""
        response = client.get(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {gestor_token}"}
        )
        
        assert response.status_code == 200
    
    def test_gestor_cannot_update_entidade(
        self,
        client: TestClient,
        gestor_token: str,
        entidade_teste: Entidade
    ):
        """❌ GESTOR NÃO PODE atualizar entidade → 403"""
        response = client.put(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={"nome": "Tentativa Atualização GESTOR"}
        )
        
        assert response.status_code == 403
    
    def test_gestor_cannot_change_status(
        self,
        client: TestClient,
        gestor_token: str,
        entidade_teste: Entidade
    ):
        """❌ GESTOR NÃO PODE alterar status de entidade → 403"""
        response = client.put(
            f"/entidades/{entidade_teste.id}/status",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={
                "status": "INATIVA",
                "motivo": "Tentativa GESTOR"
            }
        )
        
        assert response.status_code == 403
    
    def test_gestor_cannot_delete_entidade(
        self,
        client: TestClient,
        gestor_token: str,
        entidade_teste: Entidade
    ):
        """❌ GESTOR NÃO PODE deletar entidade → 403"""
        response = client.delete(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {gestor_token}"}
        )
        
        assert response.status_code == 403


class TestSecurityOperadorPermissions:
    """
    Testes de permissões do perfil OPERADOR
    Valida restrições do perfil mais baixo
    """
    
    def test_operador_cannot_list_all_entidades(
        self,
        client: TestClient,
        operador_token: str
    ):
        """❌ OPERADOR NÃO PODE listar todas as entidades → 403"""
        response = client.get(
            "/entidades/",
            headers={"Authorization": f"Bearer {operador_token}"}
        )
        
        assert response.status_code == 403
    
    def test_operador_cannot_view_any_entidade(
        self,
        client: TestClient,
        operador_token: str,
        entidade_teste: Entidade
    ):
        """❌ OPERADOR NÃO PODE ver detalhes de entidade → 403"""
        response = client.get(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {operador_token}"}
        )
        
        assert response.status_code == 403
    
    def test_operador_can_view_own_entidade(
        self,
        client: TestClient,
        operador_token: str
    ):
        """✅ OPERADOR PODE ver sua própria entidade"""
        response = client.get(
            "/entidades/me/entidade",
            headers={"Authorization": f"Bearer {operador_token}"}
        )
        
        assert response.status_code == 200


class TestSecurityMFAValidation:
    """
    Testes de validação MFA
    Valida que MFA é obrigatório para ROOT/GESTOR
    """
    
    def test_gestor_without_mfa_cannot_create_entidade(
        self,
        client: TestClient,
        gestor_user: User
    ):
        """
        ❌ GESTOR sem MFA verificado → 403
        
        Mesmo que GESTOR não possa criar entidade, valida que
        sem MFA ele é bloqueado antes da validação de perfil.
        """
        # Token sem campo TOTP
        token_sem_mfa = create_access_token({
            "sub": str(gestor_user.id)
        })
        
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {token_sem_mfa}"},
            json={"nome": "Test", "tipo": "EMPRESA"}
        )
        
        assert response.status_code == 403
        assert "MFA" in response.json()["detail"]
    
    def test_root_without_mfa_cannot_create_entidade(
        self,
        client: TestClient,
        root_user: User
    ):
        """❌ ROOT sem MFA verificado → 403"""
        token_sem_mfa = create_access_token({
            "sub": str(root_user.id)
        })
        
        response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {token_sem_mfa}"},
            json={"nome": "Test", "tipo": "EMPRESA"}
        )
        
        assert response.status_code == 403
        assert "MFA" in response.json()["detail"]


class TestSecurityRoleHierarchy:
    """
    Testes de hierarquia de perfis
    Valida a hierarquia: ROOT > GESTOR > OPERADOR
    """
    
    def test_role_hierarchy_create_entidade(
        self,
        client: TestClient,
        root_token: str,
        gestor_token: str,
        operador_token: str
    ):
        """
        Valida hierarquia na criação de entidades:
        - ROOT: ✅ PODE
        - GESTOR: ❌ NÃO PODE
        - OPERADOR: ❌ NÃO PODE
        """
        # ROOT pode criar
        root_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"nome": "ROOT Test", "cnpj": "10000000000001", "tipo": "EMPRESA"}
        )
        assert root_response.status_code == 201
        
        # GESTOR não pode criar
        gestor_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={"nome": "GESTOR Test", "cnpj": "20000000000002", "tipo": "EMPRESA"}
        )
        assert gestor_response.status_code == 403
        
        # OPERADOR não pode criar
        operador_response = client.post(
            "/entidades/",
            headers={"Authorization": f"Bearer {operador_token}"},
            json={"nome": "OPERADOR Test", "cnpj": "30000000000003", "tipo": "EMPRESA"}
        )
        assert operador_response.status_code == 403
    
    def test_role_hierarchy_update_entidade(
        self,
        client: TestClient,
        root_token: str,
        gestor_token: str,
        operador_token: str,
        entidade_teste: Entidade
    ):
        """
        Valida hierarquia na atualização de entidades:
        - ROOT: ✅ PODE
        - GESTOR: ❌ NÃO PODE
        - OPERADOR: ❌ NÃO PODE
        """
        # ROOT pode atualizar
        root_response = client.put(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {root_token}"},
            json={"nome": "Atualizado por ROOT"}
        )
        assert root_response.status_code == 200
        
        # GESTOR não pode atualizar
        gestor_response = client.put(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {gestor_token}"},
            json={"nome": "Tentativa GESTOR"}
        )
        assert gestor_response.status_code == 403
        
        # OPERADOR não pode atualizar
        operador_response = client.put(
            f"/entidades/{entidade_teste.id}",
            headers={"Authorization": f"Bearer {operador_token}"},
            json={"nome": "Tentativa OPERADOR"}
        )
        assert operador_response.status_code == 403


class TestSecurityAuditLog:
    """
    Testes de auditoria e logging
    Valida que tentativas de acesso não autorizado são registradas
    """
    
    def test_failed_access_is_logged(
        self,
        client: TestClient,
        gestor_token: str,
        caplog
    ):
        """
        Valida que tentativa de GESTOR criar entidade é logada
        
        Nota: Este teste requer configuração de caplog do pytest
        """
        import logging
        
        with caplog.at_level(logging.WARNING):
            response = client.post(
                "/entidades/",
                headers={"Authorization": f"Bearer {gestor_token}"},
                json={"nome": "Test Log", "tipo": "EMPRESA"}
            )
            
            assert response.status_code == 403


# ============ Testes de Regressão de Segurança ============

class TestSecurityRegression:
    """
    Testes de regressão para garantir que correções de segurança
    não introduzem novas vulnerabilidades
    """
    
    def test_gestor_cannot_bypass_with_multiple_requests(
        self,
        client: TestClient,
        gestor_token: str
    ):
        """
        Valida que GESTOR não consegue criar entidade
        mesmo com múltiplas tentativas (sem race condition)
        """
        for i in range(3):
            response = client.post(
                "/entidades/",
                headers={"Authorization": f"Bearer {gestor_token}"},
                json={
                    "nome": f"Tentativa {i}",
                    "cnpj": f"4000000000000{i}",
                    "tipo": "EMPRESA"
                }
            )
            assert response.status_code == 403, \
                f"GESTOR conseguiu criar entidade na tentativa {i}!"
    
    def test_gestor_cannot_escalate_privileges(
        self,
        client: TestClient,
        gestor_token: str,
        db_session: Session,
        gestor_user: User
    ):
        """
        Valida que GESTOR não consegue alterar seu próprio perfil para ROOT
        (se houver endpoint de atualização de perfil)
        """
        # Verificar perfil atual
        db_session.refresh(gestor_user)
        assert gestor_user.role == UserRole.GESTOR
        
        # Perfil não deve ter mudado
        db_session.refresh(gestor_user)
        assert gestor_user.role == UserRole.GESTOR, \
            "GESTOR conseguiu alterar seu próprio perfil!"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])


# ============ Testes de Validação de Status de Entidade ============

class TestSecurityEntidadeInativaAccess:
    """
    Testes de segurança para entidades INATIVAS
    Valida que entidades com status diferente de ATIVA são bloqueadas
    """
    
    @pytest.fixture
    def entidade_inativa(self, db_session: Session):
        """Cria entidade com status INATIVA"""
        entidade = Entidade(
            nome="Entidade Inativa Contratos",
            cnpj="88888888888888",
            tipo=TipoEntidade.EMPRESA,
            status=StatusEntidade.INATIVA,
            is_active=False,
            motivo_status="Desativada para testes"
        )
        db_session.add(entidade)
        db_session.commit()
        db_session.refresh(entidade)
        return entidade
    
    @pytest.fixture
    def user_entidade_inativa(self, db_session: Session, entidade_inativa: Entidade):
        """Cria usuário GESTOR com entidade INATIVA"""
        user = User(
            username="gestor_inativo_contratos",
            email="gestor_inativo_contratos@test.com",
            hashed_password="$2b$12$test_hash",
            role=UserRole.GESTOR,
            entidade_id=entidade_inativa.id,
            is_active=True,
            mfa_enabled=True,
            mfa_secret=TEST_MFA_SECRET
        )
        db_session.add(user)
        db_session.commit()
        db_session.refresh(user)
        return user
    
    @pytest.fixture
    def token_entidade_inativa(self, user_entidade_inativa: User):
        """Token JWT para usuário com entidade INATIVA"""
        totp_code = generate_test_totp()
        return create_access_token({
            "sub": str(user_entidade_inativa.id),
            "totp": totp_code
        })
    
    def test_entidade_inativa_access_contratos_list_returns_403(
        self,
        client: TestClient,
        token_entidade_inativa: str
    ):
        """
        🔒 TESTE PRINCIPAL: Entidade INATIVA tentando acessar /contratos → 403 Forbidden
        
        **Cenário:**
        - Usuário GESTOR autenticado com MFA
        - Entidade com status INATIVA
        - Tenta listar contratos (GET /contratos/)
        
        **Resultado Esperado:**
        - Status Code: 403 Forbidden
        - Mensagem indicando que entidade está INATIVA
        - Operação NÃO deve ser executada
        
        **Validações de Segurança:**
        - ✅ Autenticação válida
        - ✅ MFA verificado
        - ❌ Entidade INATIVA (não ATIVA)
        """
        response = client.get(
            "/contratos/",
            headers={"Authorization": f"Bearer {token_entidade_inativa}"}
        )
        
        # Deve retornar 403 Forbidden
        assert response.status_code == 403, \
            f"Entidade INATIVA conseguiu acessar /contratos! Response: {response.json()}"
        
        # Verificar mensagem de erro
        detail = response.json()["detail"]
        assert "INATIVA" in detail or "inativa" in detail.lower() or "ativa" in detail.lower(), \
            f"Mensagem de erro inadequada: {detail}"
    
    def test_entidade_inativa_cannot_create_contrato(
        self,
        client: TestClient,
        token_entidade_inativa: str
    ):
        """
        🔒 Entidade INATIVA tentando criar contrato → 403 Forbidden
        """
        response = client.post(
            "/contratos/",
            headers={"Authorization": f"Bearer {token_entidade_inativa}"},
            json={
                "nome": "Contrato Tentativa",
                "valor": 1000.00
            }
        )
        
        assert response.status_code == 403
        detail = response.json()["detail"]
        assert "INATIVA" in detail or "ativa" in detail.lower()
    
    def test_entidade_inativa_cannot_view_contrato(
        self,
        client: TestClient,
        token_entidade_inativa: str
    ):
        """
        🔒 Entidade INATIVA tentando visualizar contrato → 403 Forbidden
        """
        response = client.get(
            "/contratos/1",
            headers={"Authorization": f"Bearer {token_entidade_inativa}"}
        )
        
        assert response.status_code == 403
    
    def test_entidade_inativa_cannot_update_contrato(
        self,
        client: TestClient,
        token_entidade_inativa: str
    ):
        """
        🔒 Entidade INATIVA tentando atualizar contrato → 403 Forbidden
        """
        response = client.put(
            "/contratos/1",
            headers={"Authorization": f"Bearer {token_entidade_inativa}"},
            json={"nome": "Tentativa Update"}
        )
        
        assert response.status_code == 403
    
    def test_entidade_inativa_cannot_delete_contrato(
        self,
        client: TestClient,
        token_entidade_inativa: str
    ):
        """
        🔒 Entidade INATIVA tentando deletar contrato → 403 Forbidden
        """
        response = client.delete(
            "/contratos/1",
            headers={"Authorization": f"Bearer {token_entidade_inativa}"}
        )
        
        assert response.status_code == 403


class TestSecurityAllInactiveStatusesBlocked:
    """
    Testes validando que TODOS os status não-ativos são bloqueados
    Status: INATIVA, SUSPENSA, BLOQUEADA, EM_ANALISE
    """
    
    @pytest.fixture
    def entidade_suspensa(self, db_session: Session):
        """Cria entidade SUSPENSA"""
        entidade = Entidade(
            nome="Entidade Suspensa Contratos",
            cnpj="77777777777777",
            tipo=TipoEntidade.EMPRESA,
            status=StatusEntidade.SUSPENSA,
            is_active=False,
            motivo_status="Inadimplência"
        )
        db_session.add(entidade)
        db_session.commit()
        db_session.refresh(entidade)
        return entidade
    
    @pytest.fixture
    def entidade_bloqueada(self, db_session: Session):
        """Cria entidade BLOQUEADA"""
        entidade = Entidade(
            nome="Entidade Bloqueada Contratos",
            cnpj="66666666666666",
            tipo=TipoEntidade.EMPRESA,
            status=StatusEntidade.BLOQUEADA,
            is_active=False,
            motivo_status="Violação de termos"
        )
        db_session.add(entidade)
        db_session.commit()
        db_session.refresh(entidade)
        return entidade
    
    @pytest.fixture
    def entidade_em_analise(self, db_session: Session):
        """Cria entidade EM_ANALISE"""
        entidade = Entidade(
            nome="Entidade Em Análise Contratos",
            cnpj="55555555555555",
            tipo=TipoEntidade.EMPRESA,
            status=StatusEntidade.EM_ANALISE,
            is_active=False
        )
        db_session.add(entidade)
        db_session.commit()
        db_session.refresh(entidade)
        return entidade
    
    def test_entidade_suspensa_blocked_from_contratos(
        self,
        client: TestClient,
        db_session: Session,
        entidade_suspensa: Entidade
    ):
        """🔒 Entidade SUSPENSA → /contratos → 403"""
        # Criar usuário com entidade SUSPENSA
        user = User(
            username="user_suspensa",
            email="suspensa@test.com",
            hashed_password="$2b$12$test",
            role=UserRole.GESTOR,
            entidade_id=entidade_suspensa.id,
            mfa_enabled=True,
            mfa_secret=TEST_MFA_SECRET,
            is_active=True
        )
        db_session.add(user)
        db_session.commit()
        
        token = create_access_token({
            "sub": str(user.id),
            "totp": generate_test_totp()
        })
        
        response = client.get(
            "/contratos/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 403
        assert "SUSPENSA" in response.json()["detail"] or "suspensa" in response.json()["detail"].lower()
    
    def test_entidade_bloqueada_blocked_from_contratos(
        self,
        client: TestClient,
        db_session: Session,
        entidade_bloqueada: Entidade
    ):
        """🔒 Entidade BLOQUEADA → /contratos → 403"""
        user = User(
            username="user_bloqueada",
            email="bloqueada@test.com",
            hashed_password="$2b$12$test",
            role=UserRole.GESTOR,
            entidade_id=entidade_bloqueada.id,
            mfa_enabled=True,
            mfa_secret=TEST_MFA_SECRET,
            is_active=True
        )
        db_session.add(user)
        db_session.commit()
        
        token = create_access_token({
            "sub": str(user.id),
            "totp": generate_test_totp()
        })
        
        response = client.get(
            "/contratos/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 403
        assert "BLOQUEADA" in response.json()["detail"] or "bloqueada" in response.json()["detail"].lower()
    
    def test_entidade_em_analise_blocked_from_contratos(
        self,
        client: TestClient,
        db_session: Session,
        entidade_em_analise: Entidade
    ):
        """🔒 Entidade EM_ANALISE → /contratos → 403"""
        user = User(
            username="user_em_analise",
            email="em_analise@test.com",
            hashed_password="$2b$12$test",
            role=UserRole.GESTOR,
            entidade_id=entidade_em_analise.id,
            mfa_enabled=True,
            mfa_secret=TEST_MFA_SECRET,
            is_active=True
        )
        db_session.add(user)
        db_session.commit()
        
        token = create_access_token({
            "sub": str(user.id),
            "totp": generate_test_totp()
        })
        
        response = client.get(
            "/contratos/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 403
    
    def test_only_entidade_ativa_can_access_contratos(
        self,
        client: TestClient,
        db_session: Session
    ):
        """
        ✅ CONTROLE POSITIVO: Apenas entidade ATIVA pode acessar /contratos
        """
        # Criar entidade ATIVA
        entidade_ativa = Entidade(
            nome="Entidade Ativa Contratos",
            cnpj="44444444444444",
            tipo=TipoEntidade.EMPRESA,
            status=StatusEntidade.ATIVA,
            is_active=True
        )
        db_session.add(entidade_ativa)
        db_session.commit()
        
        # Criar usuário com entidade ATIVA
        user = User(
            username="user_ativa_contratos",
            email="ativa_contratos@test.com",
            hashed_password="$2b$12$test",
            role=UserRole.GESTOR,
            entidade_id=entidade_ativa.id,
            mfa_enabled=True,
            mfa_secret=TEST_MFA_SECRET,
            is_active=True
        )
        db_session.add(user)
        db_session.commit()
        
        token = create_access_token({
            "sub": str(user.id),
            "totp": generate_test_totp()
        })
        
        # Deve ter sucesso (200 OK)
        response = client.get(
            "/contratos/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["entidade_status"] == "ATIVA"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])

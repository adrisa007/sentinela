"""
Testes para o router PNCP
adrisa007/sentinela (ID: 1112237272)
"""
import pytest
from app.core.models import User, Entidade
from app.core.auth import get_password_hash
from app.core.schemas import UserRoleEnum


@pytest.fixture
def test_entidade(db_session):
    """Cria entidade de teste"""
    entidade = Entidade(
        nome="Entidade Teste",
        tipo="EMPRESA",
        status="ATIVA"
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade


@pytest.fixture
def test_user(db_session, test_entidade):
    """Cria usuário de teste"""
    user = User(
        username="gestor_teste",
        email="gestor@teste.com",
        # Hash pré-calculado para "senha123"
        hashed_password="$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5QNz8VQU5gzpO",
        full_name="Gestor Teste",
        role=UserRoleEnum.GESTOR.value,
        entidade_id=test_entidade.id,
        is_active=True,
        mfa_enabled=True,
        mfa_secret="TESTSECRET"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def auth_headers(client, test_user):
    """Headers de autenticação para testes"""
    response = client.post(
        "/auth/login",
        json={
            "username": "gestor_teste",
            "password": "senha123"
        }
    )
    assert response.status_code == 200
    data = response.json()
    
    # Se precisar de MFA
    if "requires_mfa" in data and data["requires_mfa"]:
        response = client.post(
            "/auth/mfa/verify",
            json={
                "username": "gestor_teste",
                "totp_code": "123456"
            }
        )
        assert response.status_code == 200
        data = response.json()
    
    token = data["access_token"]
    return {"Authorization": f"Bearer {token}"}


class TestPNCPRouter:
    """Testes para endpoints do PNCP"""
    
    def test_consultar_fornecedor_pncp_sucesso(self, client, auth_headers):
        """Teste: Consultar fornecedor no PNCP com sucesso"""
        
        response = client.get(
            "/pncp/fornecedor/12345678000190",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert data["cnpj"] == "12345678000190"
        assert "razao_social" in data
        assert "contratos_pncp" in data
        assert "total_contratos" in data
        assert "valor_total" in data
        assert isinstance(data["contratos_pncp"], list)
    
    def test_consultar_fornecedor_pncp_cnpj_invalido(self):
        """Teste: Consultar fornecedor com CNPJ inválido"""
        headers = get_auth_headers()
        
        # CNPJ com menos de 14 dígitos
        response = client.get(
            "/pncp/fornecedor/123456",
            headers=headers
        )
        
        assert response.status_code == 400
        assert "inválido" in response.json()["detail"].lower()
    
    def test_consultar_fornecedor_pncp_sem_autenticacao(self):
        """Teste: Tentar consultar sem autenticação"""
        response = client.get("/pncp/fornecedor/12345678000190")
        
        assert response.status_code == 401
    
    def test_consultar_fornecedor_pncp_com_formatacao(self):
        """Teste: Consultar com CNPJ formatado (deve limpar)"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/fornecedor/12.345.678/0001-90",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["cnpj"] == "12345678000190"
    
    def test_listar_contratos_fornecedor(self):
        """Teste: Listar contratos de um fornecedor"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/contratos/fornecedor/12345678000190",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert "contratos" in data
        assert "total" in data
        assert isinstance(data["contratos"], list)
    
    def test_listar_contratos_com_filtro_ano(self):
        """Teste: Listar contratos filtrando por ano"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/contratos/fornecedor/12345678000190?ano=2024",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        # Verificar se os contratos retornados são de 2024
        for contrato in data["contratos"]:
            assert "2024" in contrato["numero"]
    
    def test_listar_contratos_com_filtro_status(self):
        """Teste: Listar contratos filtrando por status"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/contratos/fornecedor/12345678000190?status=vigente",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        # Verificar se os contratos retornados estão vigentes
        for contrato in data["contratos"]:
            assert contrato["status"] == "VIGENTE"
    
    def test_estrutura_resposta_fornecedor(self):
        """Teste: Verificar estrutura completa da resposta"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/fornecedor/12345678000190",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        # Campos obrigatórios
        required_fields = [
            "success", "cnpj", "razao_social", "situacao_cadastral",
            "data_abertura", "porte", "natureza_juridica",
            "logradouro", "numero", "bairro", "municipio", "uf", "cep",
            "contratos_pncp", "total_contratos", "valor_total",
            "ultima_atualizacao"
        ]
        
        for field in required_fields:
            assert field in data, f"Campo {field} não encontrado na resposta"
        
        # Verificar estrutura dos contratos
        if data["contratos_pncp"]:
            contrato = data["contratos_pncp"][0]
            assert "numero" in contrato
            assert "objeto" in contrato
            assert "valor" in contrato
            assert "data_assinatura" in contrato
            assert "vigencia" in contrato
    
    def test_calculo_valor_total_contratos(self):
        """Teste: Verificar se valor total está correto"""
        headers = get_auth_headers()
        
        response = client.get(
            "/pncp/fornecedor/12345678000190",
            headers=headers
        )
        
        assert response.status_code == 200
        data = response.json()
        
        # Calcular valor total manualmente
        valor_calculado = sum(c["valor"] for c in data["contratos_pncp"])
        
        assert abs(data["valor_total"] - valor_calculado) < 0.01
        assert data["total_contratos"] == len(data["contratos_pncp"])

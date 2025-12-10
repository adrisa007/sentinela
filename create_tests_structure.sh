#!/bin/bash
# fix_test_fixtures.sh
# Corrige fixtures ausentes nos testes
# Repositório: adrisa007/sentinela (ID: 1112237272)

echo "🧪 Corrigindo Fixtures de Testes - adrisa007/sentinela (ID: 1112237272)"
echo "================================================================"
echo ""

cd /workspaces/sentinela

# 1. Criar conftest.py completo na raiz dos testes
cat > tests/conftest.py << 'CONFTEST'
"""
Configuração Global de Testes - adrisa007/sentinela (ID: 1112237272)

Fixtures compartilhadas para todos os testes.
"""
import os
import sys
import pytest
from typing import Generator
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool

# Adicionar app ao path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.main import app
from app.core.database import Base, get_db
from app.core.models import User, Entidade, UserRole, EntidadeStatus
from app.core.auth import get_password_hash

# ==========================================
# DATABASE FIXTURES
# ==========================================

# Database de teste em memória
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture(scope="function")
def db_engine():
    """Engine de banco de dados para testes"""
    engine = create_engine(
        SQLALCHEMY_TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def db_session(db_engine) -> Generator[Session, None, None]:
    """Sessão de banco de dados para testes"""
    TestingSessionLocal = sessionmaker(
        autocommit=False, 
        autoflush=False, 
        bind=db_engine
    )
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture(scope="function")
def client(db_session: Session) -> Generator[TestClient, None, None]:
    """Cliente de teste FastAPI"""
    
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()

# ==========================================
# USER FIXTURES
# ==========================================

@pytest.fixture
def root_user(db_session: Session) -> User:
    """Usuário ROOT com MFA configurado"""
    user = User(
        username="root",
        email="root@sentinela.com",
        hashed_password=get_password_hash("root123"),
        role=UserRole.ROOT,
        is_active=True,
        mfa_enabled=True,
        totp_configured=True,
        totp_secret="JBSWY3DPEHPK3PXP"  # Secret de teste
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

@pytest.fixture
def gestor_user(db_session: Session) -> User:
    """Usuário GESTOR com MFA configurado"""
    user = User(
        username="gestor",
        email="gestor@sentinela.com",
        hashed_password=get_password_hash("gestor123"),
        role=UserRole.GESTOR,
        is_active=True,
        mfa_enabled=True,
        totp_configured=True,
        totp_secret="JBSWY3DPEHPK3PXP"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

@pytest.fixture
def operador_user(db_session: Session) -> User:
    """Usuário OPERADOR"""
    user = User(
        username="operador",
        email="operador@sentinela.com",
        hashed_password=get_password_hash("operador123"),
        role=UserRole.OPERADOR,
        is_active=True,
        mfa_enabled=False,
        totp_configured=False
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

# ==========================================
# ENTIDADE FIXTURES
# ==========================================

@pytest.fixture
def entidade_ativa(db_session: Session) -> Entidade:
    """Entidade com status ATIVA"""
    entidade = Entidade(
        cnpj="12345678000199",
        razao_social="Empresa Ativa LTDA",
        nome_fantasia="Empresa Ativa",
        status=EntidadeStatus.ATIVA
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

@pytest.fixture
def entidade_inativa(db_session: Session) -> Entidade:
    """Entidade com status INATIVA"""
    entidade = Entidade(
        cnpj="98765432000188",
        razao_social="Empresa Inativa LTDA",
        nome_fantasia="Empresa Inativa",
        status=EntidadeStatus.INATIVA
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

@pytest.fixture
def entidade_suspensa(db_session: Session) -> Entidade:
    """Entidade com status SUSPENSA"""
    entidade = Entidade(
        cnpj="11122233000177",
        razao_social="Empresa Suspensa LTDA",
        nome_fantasia="Empresa Suspensa",
        status=EntidadeStatus.SUSPENSA
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

@pytest.fixture
def entidade_bloqueada(db_session: Session) -> Entidade:
    """Entidade com status BLOQUEADA"""
    entidade = Entidade(
        cnpj="44455566000166",
        razao_social="Empresa Bloqueada LTDA",
        nome_fantasia="Empresa Bloqueada",
        status=EntidadeStatus.BLOQUEADA
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

@pytest.fixture
def entidade_em_analise(db_session: Session) -> Entidade:
    """Entidade com status EM_ANALISE"""
    entidade = Entidade(
        cnpj="77788899000155",
        razao_social="Empresa Em Análise LTDA",
        nome_fantasia="Empresa Em Análise",
        status=EntidadeStatus.EM_ANALISE
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

@pytest.fixture
def entidade_teste(db_session: Session) -> Entidade:
    """Entidade genérica para testes"""
    entidade = Entidade(
        cnpj="00011122000133",
        razao_social="Empresa Teste LTDA",
        nome_fantasia="Empresa Teste",
        status=EntidadeStatus.ATIVA
    )
    db_session.add(entidade)
    db_session.commit()
    db_session.refresh(entidade)
    return entidade

# ==========================================
# AUTH TOKEN FIXTURES
# ==========================================

@pytest.fixture
def root_token(client: TestClient, root_user: User) -> str:
    """Token JWT para usuário ROOT"""
    from app.core.auth import create_access_token
    token = create_access_token(
        data={
            "sub": root_user.email,
            "role": root_user.role.value,
            "totp_verified": True
        }
    )
    return token

@pytest.fixture
def gestor_token(client: TestClient, gestor_user: User) -> str:
    """Token JWT para usuário GESTOR"""
    from app.core.auth import create_access_token
    token = create_access_token(
        data={
            "sub": gestor_user.email,
            "role": gestor_user.role.value,
            "totp_verified": True
        }
    )
    return token

@pytest.fixture
def operador_token(client: TestClient, operador_user: User) -> str:
    """Token JWT para usuário OPERADOR"""
    from app.core.auth import create_access_token
    token = create_access_token(
        data={
            "sub": operador_user.email,
            "role": operador_user.role.value
        }
    )
    return token

# ==========================================
# HELPER FIXTURES
# ==========================================

@pytest.fixture
def auth_headers(root_token: str) -> dict:
    """Headers de autenticação com token ROOT"""
    return {"Authorization": f"Bearer {root_token}"}

@pytest.fixture
def mock_totp():
    """Mock para códigos TOTP"""
    return "123456"

@pytest.fixture
def valid_totp_code():
    """Código TOTP válido para testes"""
    return "123456"

@pytest.fixture
def disable_mfa(monkeypatch):
    """Desabilita verificação MFA para testes"""
    def mock_verify_totp(*args, **kwargs):
        return True
    monkeypatch.setattr("app.core.auth.verify_totp", mock_verify_totp)

@pytest.fixture(autouse=True)
def reset_database(db_session):
    """Limpa banco de dados entre testes"""
    yield
    # Rollback de qualquer transação pendente
    db_session.rollback()

# ==========================================
# CONFIGURATION
# ==========================================

@pytest.fixture(scope="session")
def anyio_backend():
    """Backend para testes assíncronos"""
    return "asyncio"

# ==========================================
# PYTEST CONFIGURATION
# ==========================================

def pytest_configure(config):
    """Configuração pytest"""
    config.addinivalue_line(
        "markers", "unit: marca teste como unitário"
    )
    config.addinivalue_line(
        "markers", "integration: marca teste como integração"
    )
    config.addinivalue_line(
        "markers", "e2e: marca teste como end-to-end"
    )
    config.addinivalue_line(
        "markers", "slow: marca teste como lento"
    )

# Repository: adrisa007/sentinela | ID: 1112237272
CONFTEST

echo "✓ conftest.py criado"

# 2. Criar pytest.ini atualizado
cat > pytest.ini << 'PYTEST'
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --tb=short
    --strict-markers
    --disable-warnings
    --cov=app
    --cov-report=term-missing
    --cov-report=html
markers =
    unit: Unit tests
    integration: Integration tests  
    e2e: End-to-end tests
    slow: Slow running tests
filterwarnings =
    ignore::DeprecationWarning
    ignore::PendingDeprecationWarning
PYTEST

echo "✓ pytest.ini atualizado"

# 3. Atualizar requirements-dev.txt
cat > requirements-dev.txt << 'REQDEV'
# Testing
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
pytest-mock==3.12.0
httpx==0.25.2
faker==22.0.0

# Code Quality
black==23.12.1
flake8==6.1.0
mypy==1.8.0
isort==5.13.2
pylint==3.0.3

# Development
ipython==8.19.0
ipdb==0.13.13
REQDEV

echo "✓ requirements-dev.txt atualizado"

# 4. Rodar testes
echo ""
echo "🧪 Rodando testes..."
pytest tests/ -v --tb=short -x

echo ""
echo "================================================================"
echo "✅ FIXTURES CORRIGIDAS"
echo "================================================================"
echo ""
echo "📦 Repositório: adrisa007/sentinela"
echo "🆔 Repository ID: 1112237272"
echo ""
echo "✅ Fixtures criadas:"
echo "  • client (TestClient)"
echo "  • db_session (SQLAlchemy Session)"
echo "  • db_engine (SQLAlchemy Engine)"
echo "  • root_user, gestor_user, operador_user"
echo "  • entidade_ativa, entidade_inativa, etc"
echo "  • root_token, gestor_token, operador_token"
echo "  • auth_headers"
echo "  • mock_totp, valid_totp_code"
echo "  • disable_mfa"
echo ""
echo "📊 Executar testes:"
echo "  pytest tests/ -v"
echo "  pytest tests/ --cov=app"
echo "  pytest tests/test_auth.py -v"
echo ""
echo "✨ Fixtures prontas para uso!"
echo ""
cd /workspaces/sentinela

# Atualizar conftest.py para mockar TOTP automaticamente
cat > tests/conftest.py << 'EOF'
"""
Configuração de Testes - adrisa007/sentinela (ID: 1112237272)
"""
import sys
from pathlib import Path

repo_root = Path(__file__).parent.parent if Path(__file__).parent.name == "tests" else Path(__file__).parent
sys.path.insert(0, str(repo_root))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from unittest.mock import patch

from app.main import app
from app.core.database import Base, get_db

SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///:memory:"

# ==========================================
# MOCK TOTP VERIFICATION
# ==========================================

@pytest.fixture(autouse=True)
def mock_totp_verification(monkeypatch):
    """
    Mocka verificação TOTP para sempre retornar True em testes
    """
    def mock_verify_totp(*args, **kwargs):
        return True
    
    # Mock da função verify_totp
    monkeypatch.setattr("app.core.auth.verify_totp", mock_verify_totp)
    monkeypatch.setattr("app.core.dependencies.verify_totp", mock_verify_totp)

# ==========================================
# DATABASE FIXTURES
# ==========================================

@pytest.fixture
def db_engine():
    engine = create_engine(
        SQLALCHEMY_TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def db_session(db_engine):
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=db_engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture
def client(db_session):
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
# HELPER FIXTURES
# ==========================================

@pytest.fixture
def mock_redis_connected(monkeypatch):
    """Mock Redis como conectado"""
    def mock_ping():
        return True
    monkeypatch.setattr("app.redis_client.redis_client.ping", mock_ping)

@pytest.fixture
def mock_redis_disconnected(monkeypatch):
    """Mock Redis como desconectado"""
    def mock_ping():
        raise ConnectionError("Redis unavailable")
    monkeypatch.setattr("app.redis_client.redis_client.ping", mock_ping)

# Repository: adrisa007/sentinela | ID: 1112237272
EOF

# Rodar testes novamente
pytest tests/ -v --tb=short -x